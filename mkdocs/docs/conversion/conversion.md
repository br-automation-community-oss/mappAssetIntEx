This guide provides details how to convert the official mappAssetInt package to the community version.

### Installation
The fastest way to convert the official mappAssetInt package to a community version is to use the package from the sample as a template. Copy the package "exAssetInt" into your project.

### Transfer existing configuration
Open the assetInt configuration in the configuration view. Everything above shift can be ignored. Write down the shift details.
![](./conv1.jpg)

Open the sample task and copy the shift details into the task. The data can also be entered into the variable declaration.

![](./conv2.jpg)

The same structure is used to enter the export configuration.

![](./conv3.jpg)

Export parameters are optional. You can also use the default values.

### Additional configuration
The only mandatory additional configuration is the device name. Since the community version uses the flash card to store data it is necessary to enter the device name. The device name is defined under the CPU configuration under file devices.

![](./conv4.jpg)

### Optional configuration
The default configuration should work for most applications. However, the following parameters can be adjusted if necessary. For a detailed description see the [appendix](appendix.md).

![](./conv5.jpg)

### Connect the function blocks

All function blocks and variable structures have the exact same name as before. The only difference is the prefix. The prefix "Mp" was changed to "ex". For example, "MpAssetIntCore" was changed to "exAssetIntCore".

### Remove old AssetInt

To remove the old assetInt configuration delete configuration file under the configuration view. If there is no other mappService used you can also set the mappService to "not defined".

![](./conv6.jpg)
