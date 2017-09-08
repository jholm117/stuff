module Game.StateMethods exposing (..)


import Game.Types exposing (..)


transferMoney : Model -> MoneyEntity -> MoneyEntity -> Coins -> Model
transferMoney model giver taker amount =
    if giver.wallet >= amount then
      ({ model : giver= })
