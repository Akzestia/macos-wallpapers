# MacOS wallpapers

A small cli app that allows you to set custom wallpapers on macos

<img width="3440" height="1440" alt="image" src="https://github.com/user-attachments/assets/5c073f61-5b1e-493e-9cfa-cbe4adcc85ff" />

# Usage 

```sh
wallpapers --path <path_to_your_video>
```
> [!TIP]
> To run in bg on macOS
> ```sh
> #!/bin/bash
> nohup wallpapers --path <path_to_your_video> > /dev/null 2>&1
> # Example
> nohup ./build/wallpapers --path ./assets/x2.mp4> /dev/null 2>&1 &
> ```
