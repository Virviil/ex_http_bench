# ExHttpBench

**Benchmarking popular HTTP clients**

## Results

| Client                 | Runtime | Wall clock | Memory (MB) | Failures |
|------------------------|---------|------------|-------------|----------|
| Hackney (default pool) | 59691   | 50888      | 14.837      | 0        |
| HTTPC                  | 47906   | 42531      | 27.059      | 0        |
| HTTPC Optimized        | 50802   | 45300      | 28.631      | 0        |
| LHTTPC                 | 46361   | 38610      | 80.735      | 0        |
| IBrowse                | 58724   | 49948      | 15.141      | 0        |
| IBrowse (optimized)    | 58199   | 49791      | 11.781      | 0        |

> HP Notebook, Intel CORE i5, 4GB RAM, Arch Linux

## Running

1. Deal with SSL - project expects `localhost.ssl` to be resolved onto `localhost`
2. Start server in **first TTY**:
    ```bash
    $ ./bin/run
    iex> ExHttpBench.Server.start
    ...
    ```
3. Run clients in **second TTY**:
    ```bash
    $ ./bin/run
    iex> ExHttpBench.Client.%YOUR_CLIENT_NAME%
    ...
    ```
