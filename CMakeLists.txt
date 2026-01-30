cmake_minimum_required(VERSION 4.0.1)
project(wallpapers LANGUAGES CXX OBJCXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0")

add_executable(wallpapers main.mm)

target_link_libraries(wallpapers
    "-framework Cocoa"
    "-framework AVFoundation"
    "-framework CoreMedia"
)
