# Postmortem

This project was pretty smooth to work on. I think the only part that I actually had issues with was trying to make the turn resolve not all in one frame (which I ended up decided needed a full rewrite of the systems and I didn't have time to do that). Working on everything else went really well though. I think one of the smoothest parts was adding new cards to the game, which using the prototype and subclass sandbox setup I built was extremely easy.

This project is much more complete than most of my other projects (I'm generally really bad at actually finishing projects). Despite this project being more complete than my other projects, I think it is definitely much less complex than the things I normally work on (one of my side projects is me trying to build a toy game engine just for the learning experience, which is both super complicated and nowhere near complete).

I think the thing that I am most proud of on this project is the card prototype/subclass sandbox thing, since it's just super nice to work with. I think the biggest thing that didn't work was trying to make the game run a bit less instantly (not having turns resolve in 1 frame), which the way I wrote the player and turn managing system just wasn't possible without a lot of changes (that I didn't really have time to make).

I'm not sure if I'd work on a card game like this again (unless it was as a job), mostly just because they aren't all that interesting to me, especially compared to my other ideas.

I think some of the other cool stuff was what I just added with the deck building system, since I built an area where you can scroll complete with a scrollbar and proper clipping so that you don't see things out of range and can see where in the scroll region you are (bonus that it basically worked within 5 minutes of me implementing it, which always feels good).

I think the deckbuilding did have a funny bug at one point where you could't remove cards from the deck and it instead just kept adding Wooden Cows to your deck (which ended up being caused by an indexing bug mixed with an error in detecting if a card is in the deck or not so that I knew whether or not I should be removing or adding cards).