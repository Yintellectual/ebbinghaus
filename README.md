# Clone and Setup

So far, HarmonyOS the latest version is 5.0.0, corresponding HarmonyOS API version is 12, model version is 5.0.0

1. set modelVersion to 5.0.0 in files:
    - ~\oh-package.json5
    - ~\hvigor\hvigor-config.json5
2. Reset Signing Configuration in Project Structure
`File` > `Project Structure` > `Signing Configs` > check `automatically generate signature`
   -  the corresponding file "build-profile.json5" is added into gitignore
