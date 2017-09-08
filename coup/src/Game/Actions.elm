module Game.Actions exposing (..)

import Game.Types exposing (..)


actionList : List Action
actionList =
    [ Action Income "Income" Unstoppable (TakeMoney BankTarget 1) Neutral
    , Action ForeignAid "Foreign Aid" Blockable (TakeMoney BankTarget 2) Neutral
    , Action Tax "Tax" Challengeable (TakeMoney BankTarget 3) (NonNeutral Duke)
    , Action Steal "Steal" BlockableAndChallengeable (TakeMoney PlayerTarget 2) (NonNeutral Captain)
    , Action Assassinate "Assassinate" BlockableAndChallengeable (Cost 3) (NonNeutral Assassin)
    , Action Exchange "Exchange" Challengeable NonCondition (NonNeutral Ambassador)
    , Action Coup "Coup" Unstoppable (Cost 7) Neutral
    ]


type TransactionType
    = Deposit
    | Withdrawal


p2pTransferCoins : Coins -> PlayerID -> PlayerID -> Model -> Model
p2pTransferCoins amount giverID takerID model =
    let
        updatedPlayers =
            List.map
                (\p ->
                    if p.id == giverID then
                        { p | wallet = p.wallet - amount }
                    else if p.id == takerID then
                        { p | wallet = p.wallet + amount }
                    else
                        p
                )
                model.players
    in
        { model | players = updatedPlayers }


transferWithBank : TransactionType -> Coins -> PlayerID -> Model -> Model
transferWithBank transType coins id model =
    let
        amount =
            case transType of
                Deposit ->
                    coins * -1

                Withdrawal ->
                    coins

        players =
            List.map
                (\p ->
                    if p.id == id then
                        { p | wallet = p.wallet + amount }
                    else
                        p
                )
                model.players
    in
        { model | players = players, bank = model.bank - amount }


drawTwoCards : PlayerID -> Model -> Model
drawTwoCards id model =
    dealCard id model
        |> dealCard id


dealCard : PlayerID -> Model -> Model
dealCard targetPlayerID model =
    let
        dealtCard =
            case List.head model.deck of
                Nothing ->
                    errorCard

                Just dealtCard ->
                    dealtCard

        updatedDeck =
            case List.tail model.deck of
                Nothing ->
                    List.singleton errorCard

                Just restOfDeck ->
                    restOfDeck

        updatePlayer player =
            if player.id == targetPlayerID then
                { player | hand = dealtCard :: player.hand }
            else
                player

        updatedPlayers =
            List.map updatePlayer model.players
    in
        { model | players = updatedPlayers, deck = updatedDeck }


recursiveAction : PlayerID -> (PlayerID -> Model -> Model) -> Model -> Model
recursiveAction currID action model =
    let
        ids =
            List.map (\p -> p.id) model.players
    in
        case List.member currID ids of
            False ->
                model

            True ->
                action currID model
                    |> recursiveAction (currID + 1) action


availableActions : Model -> List Action
availableActions model =
    let
        isAvailable action =
            case action.condition of
                Cost coins ->
                    List.any (\p -> model.currentPlayerID == p.id && p.wallet >= coins) model.players

                NonCondition ->
                    True

                TakeMoney target amount ->
                    case target of
                        PlayerTarget ->
                            List.any (\p -> p.wallet >= amount) model.players

                        BankTarget ->
                            model.bank >= amount
    in
        List.filter isAvailable actionList


changePlayerState : PlayerID -> TurnState -> Players -> Players
changePlayerState id newState players =
    List.map
        (\p ->
            if p.id == id then
                { p | state = newState }
            else
                p
        )
        players
