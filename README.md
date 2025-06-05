# 3CG - Casual Card Cacophony

## Patterns Used
- Prototype (used to make the cards themselves and overall improves the experience of adding new cards, since I make a prototype card based on a base prototype card, and then can spawn cards based on that prototype however I want to, which is useful for cards like hydra)
- Flyweight (used for things like fonts or the library of card types, prevents me from doing the same thing several times when it's not necessary)
- Singleton (the game state is a singleton object, since I only run one game at a time. This helped a lot with making things work well together since I could provide functions that modify game state safely instead of just having tons of places where I randomly change variables for no reason)
- Subclass Sandbox (the base card class is a subclass sandbox, providing a few callback functions and several utilities that allow you to easily customize card functionality. This lets me have very short card definitions, only a dozen or so lines of code instead of the many many more I would need for some other methods)
- Game Loop and Update Function (these are pretty core to both how things work and how LOVE2D works, since LOVE2D manages the game loop and then calls the draw and update functions, which I just pass to other objects)

## Feedback
I got feedback from Hunter Kingsly somewhat early on in the development of this project. He helped me to think through some of my problems at the time (namely trying to figure out how to get cards interacting with eachother correctly). I don't have any written feedback from him, though, and this was more of a problem solving/small bits of feedback than it was code review.
I also got feedback (written) from Joshua Acosta about my code much further along in the process. He made some suggestions (namely suggesting making a turn managing system) which I plan to implement for the final version, but don't have time to implement for this one. A pdf of his feedback can be found in the `/feedback` folder of this repository.

## Postmortem
I think this project has gone fairly well. I wish I had finished it sooner so that I didn't get so stressed over it, but code wise I think it's fairly good. I think the biggest pain point in the project was making cards work properly together. I also need to do some rebalancing for the version for the final. I also want to make things look better (adding delays since I definitely do the whole turn in one frame right now since I didn't have time to make it pause and resume). If I did this over again, I would make resolving command based instead of a normal function (which I may do for the final version, it wouldn't be that hard to make the cards feed into a command queue thing, then I could animate more).

## Assets
All Me!
