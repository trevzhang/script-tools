use std::collections::HashMap;
use regex::Regex;
use serde_json::{json, Value, Map};
use clap::Parser;
use url::Url;
use copypasta::{ClipboardContext, ClipboardProvider};

#[derive(Parser, Debug)]
#[clap(author, version, about, long_about = None)]
struct Args {
    /// The input string to parse
    #[clap(value_parser)]
    input: String,

    /// Output as JSON
    #[clap(short, long)]
    json: bool,

    /// Parse as URL query string
    #[clap(short, long)]
    url: bool,

    /// Copy output to clipboard
    #[clap(short, long)]
    clip: bool,
}

fn parse_java_to_string(s: &str) -> Map<String, Value> {
    let mut result = Map::new();
    let re = Regex::new(r#"(\w+)=(?:([^,(){}]+)|(\{[^{}]*\})|(\([^()]*\))|(<[^<>]*>))(?:,|$)"#).unwrap();

    for cap in re.captures_iter(s) {
        let key = cap[1].to_string();
        let value = cap.get(2).or_else(|| cap.get(3)).or_else(|| cap.get(4)).or_else(|| cap.get(5)).unwrap().as_str();
        let parsed_value = parse_value(value);
        result.insert(key, parsed_value);
    }

    result
}

fn parse_value(v: &str) -> Value {
    let v = v.trim();
    if v == "null" {
        Value::Null
    } else if v.starts_with('{') && v.ends_with('}') {
        match serde_json::from_str(v) {
            Ok(json) => json,
            Err(_) => json!(parse_java_to_string(&v[1..v.len()-1]))
        }
    } else if v.contains('(') && v.ends_with(')') {
        let parts: Vec<&str> = v.splitn(2, '(').collect();
        let class_name = parts[0];
        let content = &parts[1][..parts[1].len()-1];
        json!({class_name: parse_java_to_string(content)})
    } else if v.starts_with('<') && v.ends_with('>') {
        Value::String(v.to_string())
    } else if let Ok(i) = v.parse::<i64>() {
        Value::Number(i.into())
    } else if let Ok(f) = v.parse::<f64>() {
        json!(f)
    } else {
        Value::String(v.to_string())
    }
}

fn format_output(data: &Map<String, Value>, indent: usize) -> String {
    let mut output = String::new();
    for (key, value) in data {
        match value {
            Value::Object(obj) if obj.len() == 1 && obj.values().next().unwrap().is_object() => {
                let class_name = obj.keys().next().unwrap();
                output.push_str(&format!("{:indent$}{}: {}(\n", "", key, class_name, indent = indent * 2));
                output.push_str(&format_output(&obj[class_name].as_object().unwrap(), indent + 1));
                output.push_str(&format!("{:indent$})\n", "", indent = indent * 2));
            },
            Value::Object(obj) => {
                output.push_str(&format!("{:indent$}{}:\n", "", key, indent = indent * 2));
                output.push_str(&format_output(obj, indent + 1));
            },
            _ => output.push_str(&format!("{:indent$}{}: {}\n", "", key, value, indent = indent * 2)),
        }
    }
    output
}

fn parse_url_query(input: &str) -> Map<String, Value> {
    let mut result = Map::new();
    let url_str = if !input.starts_with("http://") && !input.starts_with("https://") {
        format!("http://example.com/{}", input)
    } else {
        input.to_string()
    };

    if let Ok(url) = Url::parse(&url_str) {
        for (key, value) in url.query_pairs() {
            result.insert(key.into_owned(), Value::String(value.into_owned()));
        }
        if let Some(fragment) = url.fragment() {
            result.insert("fragment".to_string(), Value::String(fragment.to_string()));
        }
    }

    result
}

fn main() {
    let args = Args::parse();

    let parsed_data = if args.url {
        parse_url_query(&args.input)
    } else {
        parse_java_to_string(&args.input)
    };

    let output = if args.json {
        serde_json::to_string_pretty(&parsed_data).unwrap()
    } else {
        format_output(&parsed_data, 0)
    };

    if args.clip {
        let mut ctx = ClipboardContext::new().expect("Failed to create clipboard context");
        ctx.set_contents(output.clone()).expect("Failed to set clipboard contents");
        println!("Output copied to clipboard.");
    }

    print!("{}", output);
}