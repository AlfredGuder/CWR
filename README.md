# CWR

This is a readme for CWR

This project uses Hive for its local storage. 
In order to have changes save when running in web mode during development you need to force flutter to use the same port each time.

To do this add the following configuration to your `launch.json`

```json
{
    "name": "CWR (Fixed Port)",
    "request": "launch",
    "type": "dart",
    "toolArgs": ["-d", "chrome", "--web-port=9001"]
}
```
