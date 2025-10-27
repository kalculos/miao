# miao

MIAO~ stands for Moonbit Input And Output. It is a well-designed and general purposed I/O library with portable runtime support. 

It consists of `rt` (runtime), `fs` (filesystem) and `codec` (data encoding and decoding, possibly networking clients). We also targets Network I/O but, like other libraries, are under heavy construction and may change rapidly.

Project status: https://github.com/orgs/kalculos/projects/4

This project uses [version evolution](https://github.com/saltedfishclub/documents/blob/main/Evolution_EN.md) strategy from saltedfishclub, with an additional complement:
 - For a new version, _every_ package in this repository are published simultaneously.

# Some graphs
that may change in fuuuture


```mermaid
graph TD
    subgraph APIs
        subgraph rt.Runtime
            Context --"manages"--> Task
        end
        io --> fs
        io --> net
        rt.Runtime <--"runtime depends on io but hard to graph beautifully"--> io
        rt.Runtime --> pipe
        io --> pipe
        io --> tty
        rt.Runtime --> fs
        rt.Runtime --> net
        tty <--> pipe
    end
    subgraph Codec
        Minecraft
        Deflate
        HTTP
        TLS
    end
    io --> Codec
    subgraph LibuvRT 
        libuv/uv.mbt --> LibuvRuntime
        subgraph LibuvRuntime
            LibuvFS
            UvTask --"Bound To" -->Coroutine
            
        end
    end
    LibuvRuntime -- "implements" --> rt.Runtime
``` 

```mermaid
graph TD
    subgraph "Task State Transition"
        New --> Running --> Suspend --> Running --> Completed
        subgraph Cancellation 
            New_("New") --> Cancelled
            Suspend_("Suspend") --> Cancelled
            Suspend_ --> Transition["Is Cancelling"] --"No"--> Running_("Running")
            Transition --"Yes"--> Cancelled
            Running_ --> Transition --"No" --> Suspend_
        end
    end
```

```mermaid
graph TD
    Cancel{"Cancel"} --"Cancel/Join"--> Context
    Context --"Cancel/Join" --> Children@{shape: docs, label: "children"}
    Context --"Cancel/Join" --> Tasks@{shape: docs, label: "Tasks"}
```
