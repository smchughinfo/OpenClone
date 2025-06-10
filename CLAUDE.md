# OpenClone Project

## Core Architectural Principle
**Minimum Learning Curve**: One of the main architectural tenants of this project is that it should work with minimal setup for new users. You should be able to download the entire repository, setup a few dependencies if needed (like CUDA, .NET, PostgreSQL), click build and the entire solution is up and running. This principle drives design decisions throughout the project and is where the overall architecture was heading.

## Project Status
- Massive project refactor in progress:
  * Directory structure changed: 
    - 'website' previously called 'OpenClone'
    - 'OpenClone' is now the root directory
    - 'databaserestore' renamed to 'database'
    - 'StartStopScripts' previously inside Website
  * Container naming convention: all project containers prefixed with 'openclone-'
    - Examples: openclone-website, openclone-SadTalker, openclone-U-2-Net, openclone-CICD
  * Anticipating potential issues during project revival