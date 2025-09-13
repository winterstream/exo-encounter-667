# ECS(-ish) refactoring of EXO_encounter 667

This repo is an ECS adaptation of Phil Hagelberg's [EXO_encounter 667](
  https://gitlab.com/technomancy/exo-encounter-667).

I wanted to understand how one goes about converting a single large
state-machine architecture into an ECS-based architecture. I initially
set out to build upon Calvin Rose's tiny-ecs but it turned out that
entities are in known locations:
- the probe and rovers are in the state module,
- doors and sensors can be read directly from the Tiled map,
- all other entities are singletons.

So in the end, I chose to forgo using an ECS library and instead
implemented systems as a number of classes.

## Architecture

This refactoring retains Phil Hagelberg's state management system
but uses states only to model coarse games states:
1. intro
2. main (main gameplay state)
3. pause
4. term (when the terminal view is active)
5. win (game ending)

States call systems in their draw and update functions to handle 
drawing and game state updates. The intro and pause states each
use a single system (splash-screen-system) while the main state
uses the rest.

## Isn't this unnecessarily heavy?

There definitely is more boiler plate in this version and a wee
bit more overhead. But the source code organization shows which
parts of the game logic are independent which hopefully makes
learning how the game works a little easier.

Should you use a similar approach when making small games? I
mean, use what works for you but I'd probably use an ECS-like
approach like this one even if my game doesn't warrant the
use of an ECS library.

## Licenses

Original code, prose, map, and images copyright © 2018 [Dan Larkin](https://danlarkin.org), [Phil Hagelberg](https://technomancy.us), Zach Hagelberg, and Noah Hagelberg.

Distributed under the GNU General Public License version 3 or later; see file license.txt.

Licensing of third-party art and libraries described in [credits](credits.md)
