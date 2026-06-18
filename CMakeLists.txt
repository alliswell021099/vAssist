cmake_minimum_required(VERSION 3.16)

project(vAssist VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick)

qt_add_executable(vAssist
    main.cpp
    core/agent/AgentKernel.cpp
    core/agent/AgentKernel.h
    core/providers/MockProvider.cpp
    core/providers/MockProvider.h
    core/providers/LLMProvider.h
    resources.qrc
)

target_include_directories(vAssist PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(vAssist PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
)
