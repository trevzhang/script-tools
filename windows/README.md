# hyperv.bat

一个简单的批处理文件，用于切换Hyper-V的启动类型。你可以选择启用、禁用Hyper-V启动类型，或者重启系统。

> WSL与模拟器不兼容，无法同时运行？
> 这里给出另一种解决方案：https://blog.csdn.net/zhihao_li/article/details/131248100

## 将WSL2降级为WSL1
由于WSL2使用虚拟化技术，WSL2使用开启了虚拟化（即1.2启动虚拟功能），会对VMware和codemeters产生影响。VMware虚拟机不能开启虚拟化，codemeters认为软件启动在虚拟机中，无法启动。因此，需要将WSL2降级为不需要开启虚拟化的WSL1，并将虚拟化关闭。步骤如下：

1. 管理员权限打开Powershell
2. 查看版本号
输入命令wsl -l -v，

3. 降WSL版本：
输入wsl --set-version [NAME] 1

4. 关闭虚拟化
转换完成之后，输入命令

Disable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform

转换完成后输入Y，重启电脑。

5. 查看版本
如果VERSION变为1，则表示转换成功，此时能同时正常使用wsl、Vmware虚拟化。

如果仍然提示启动设备失败，请重新关闭依次虚拟机平台。步骤：

> 1.打开控制面板->程序和功能->启动或关闭Windows功能，查看虚拟机平台是否处于关闭状态（要求为关闭状态）。
> 
> 2.如果处于打开状态，则关闭，确定后重启电脑。
> 
> 3.如果处于关闭状态，则打开，确定，重启电脑，在再进入此界面，将此选项关闭后再次重启电脑

