# Push swap checker

Scripts to check various things for the *push_swap* project at [42](https://www.42.fr):
- **checker_tests.sh**: tests different valid and invalid inputs + leaks for the checker program
- **push_swap_tests.sh**: run tests for the push_swap program with different lists of random numbers and calculate the average, minimum and maximum number of instructions (+ leaks)

## Getting started

```
git clone https://github.com/jkgithubrep/42_push_swap_checker.git
```

Change the path to you push_swap project at the top of both scripts

## Usage

### Checker

```
Usage: sh checker_tests.sh [tests numbers]
Example:
 sh checker_tests.sh 1 4 5
       > run checker only for tests n°1, n°4 and n°5
```

### Push_swap

```
Usage: ./push_swap_tests.sh [options] nb_of_tests lower_bound upper_bound nb_of_elm
Example:
 sh push_swap_tests.sh -c 150 -200 200 100
      > test checker
      > run 150 different tests with generated lists of 100 random numbers between -200 and 200
Options:
 -h, --help                Display usage
 -a, --all                 Check everything
 -c, --checker             Check checker
 -v, --verbose             Print tests
 -l, --leaks               Check leaks
```

## Issues

If you encounter any issue, you can contact me on slack (jkettani) or by email: jkettani@student.42.fr


## Author

by **jkettani**

