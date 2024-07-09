# MLSqueeze experiments for SBFT 2024

[MLSqueeze](https://github.com/feldob/MLSqueeze) is a tool that helps identify boundary candidates for classifiers. This repository serves as a reproduction package for the experiments from the original research paper ([https://doi.org/10.1145/3643659.3643927](https://doi.org/10.1145/3643659.3643927)):

```
@inproceedings{dobslaw2024automated,
  title={Automated Boundary Identification for Machine Learning Classifiers},
  author={Felix Dobslaw and Robert Feldt},
  booktitle={2024 ACM/IEEE International Workshop on Search-Based and Fuzz Testing (SBFT '24)},
  year={2024},
  doi={10.1145/3643659.3643927}
}
```

You execute the scripts by doing the following:

- install Julia in its latest version (tested with Julia 1.9.x and 1.10.x)
- open the REPL by writing `julia` in your terminal of choice.
- run the experiments by executing `include("src/experiments.jl")`.

The experimental results can then be found under the `experiments` directory, while plots and statistics will be found under `stats`.

## License

This project is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) License.