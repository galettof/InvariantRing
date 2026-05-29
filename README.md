# InvariantRing
[Macaulay2](https://macaulay2.com) package for computing invariants of linear group actions on rings.
For an overview, see [The InvariantRing package for Macaulay2](https://msp.org/jsag/2024/14-1/p02.xhtml).

## History
- The first version of this package was developed by Thomas Hawes. See [Computing the invariant ring of a finite group](https://msp.org/jsag/2013/5-1/p03.xhtml) for more details.
- Version 2.0 was developed by Luigi Ferraro, Federico Galetto, Francesca Gandini, Hang Huang, Matthew Mastroeni and Xianglong Ni during the 2020 [Macaulay2 Workshop at Cleveland State University](https://math.galetto.org/m2csu/).
- See [Releases](https://github.com/galettof/InvariantRing/releases) for later versions. The current maintainer is [Federico Galetto](https://math.galetto.org).

# Using InvariantRing

## Getting started

- The InvariantRing package is included in the official Macaulay2 distribution, so it can be used out of the box in a [local installation](https://github.com/Macaulay2/M2/wiki) or in a [Macaulay2Web server](https://macaulay2.com/TryItOut/).
- Thanks to Al Ashir Intisar and Francesca Gandini, you can also run Macaulay2 + InvariantRing in a codespace, which is good for small computations or to start writing code directly from your browser without installation. To do so:
  1. [fork this repository](https://github.com/galettof/InvariantRing/fork);
  2. switch to the desired branch from the top left dropdown menu;
  3. click the **<> Code** button at the top right;
  4. select **Codespaces** and click the **Create codespace on ...** button.
  
  For a more detailed how-to with pictures, please see [fragandi/M2-codespace](https://github.com/fragandi/M2-codespace).

## Documentation

To start using InvariantRing, issue the command

`needsPackage "InvariantRing"`

in a running session of Macaulay2, then issue

`viewHelp "InvariantRing"`

to view the documentation.
The `examples` folder in this repository contains examples of computations that can be performed using this package.

# Contributing to InvariantRing

## Feature requests and development

If you have suggestions for new features or if you would like to implement new features yourself, please open a new issue with the 'Feature request' template. Once the request is evaluated, a new feature branch will be created and any progress will be tracked in the discussions for that issue so that others are kept informed of current development status. To develop code for the new feature, please fork the repository and then issue a pull request against the feature branch when you are done.

## Reporting a bug

If you encounter a bug, please open a new issue in this repository using the 'Bug report' template.
