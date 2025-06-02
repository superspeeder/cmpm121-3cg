---@enum Trigger
Trigger = {
    OnReveal = "on-reveal",
    OnCardPlayedHere = "on-card-played-here",
    OnDiscarded = "on-discarded",
    EndOfTurn = "end-of-turn",
    OnAllyCardPlayedHere = "on-ally-card-played-here",
    OnEnemyCardPlayedHere = "on-enemy-card-played-here",
}

---@enum Condition
Condition = {
    PowerLessThanOrEqual = "power-less-than-or-equal",
    PowerGreatherThan = "power-greater-than",
    IsWinningLocation = "is-winning-location",
    CardCountIs = "card-count-here-is",
    StrongestCard = "strongest-card",

}


---@enum Target
Target = {
    PlayerHand = "player-hand",
    OpponentsHand = "opponents-hand",
    ContextTarget = "context-target", -- This is used for cards like Medusa, who changes the card causing a trigger
    CardsHere = "cards-here",
    OtherCardsHere = "other-cards-here",
    AllyCardsHere = "ally-cards-here",
    EnemyCardsHere = "enemy-cards-here",
    ChooseFrom = "chose-from", -- this is a special one that lets you choose N targets from a target set
    LowestPower = "lowest-power", -- Targets the lowest power card in a target set
    PlayerDiscardPile = "player-discard-pile",
}

---@enum ActionType
ActionType = {
    ChangePowerOfCardsBy = "change-power-of-cards-by",
    GainPowerPerTarget = "gain-power-per-target",
    DiscardAndGainPowerPerTarget = "discard-and-gain-power-per-target", -- discards target cards and gains +n power per discarded target
    SetPower = "set-power",
    GainManaNextTurn = "gain-mana-next-turn",
    ChangeCostOfTargets = "change-cost-of-targets",
    DiscardAndAddTargetPowerToTarget = "discard-and-add-target-power-to-target", -- name is a bit confusing, but this just takes a single target card (the caller) and adds the power of all cards in a target set to it, and discards those cards.
    DiscardThis = "discard-this",
    AddCardToOtherLocations = "add-card-to-other-locations",
    AddCopiesToHand = "add-copies-to-hand",
    DoublePower = "double-power",
    MoveAwayCard = "move-away-card",
}


