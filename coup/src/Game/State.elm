module Game.State exposing (..)

import Game.Actions as Actions exposing (changePlayerState)
import Game.Types exposing (..)
import Random
import Random.List exposing (shuffle)


startingBankCash : Coins
startingBankCash =
    50


initialModel : Model
initialModel =
    { players = []
    , deck = []
    , currentPlayerID = 1
    , bank = 0
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ActionMsg action ->
            let
                players =
                    List.map
                        (\p ->
                            if p.id == model.currentPlayerID then
                                { p | state = Waiting }
                            else
                                { p | state = Responding action }
                        )
                        model.players
            in
                ( { model | players = players }, Cmd.none )

        UpdateDeckMsg newDeck ->
            let
                shuffledModel =
                    { model | deck = newDeck }
            in
                ( dealAllPlayers shuffledModel, Cmd.none )

        StartGameMsg numPlayers ->
            let
                newModel =
                    generateGameObjects numPlayers
            in
                ( newModel, Random.generate UpdateDeckMsg (shuffle newModel.deck) )

        ResponseMsg response playerID ->
            let
                players =
                    List.map
                        (\p ->
                            if playerID == p.id then
                                { p | state = Waiting }
                            else
                                p
                        )
                        model.players

                aModel =
                    { model | players = players }

                newModel =
                    handleResponse response playerID aModel

                newestModel =
                    if List.all (\p -> p.state == Waiting) players then
                        endTurn newModel
                    else
                        newModel
            in
                ( newestModel, Cmd.none )

        FlipCardMsg card id ->
            ( model, Cmd.none )


generateGameObjects : Int -> Model
generateGameObjects numPlayers =
    let
        newPlayers =
            List.map
                (\n ->
                    let
                        playerState =
                            if n == 1 then
                                DecidingAction
                            else
                                Waiting
                    in
                        Player [] 2 n playerState
                )
                (List.range 1 numPlayers)

        newDeck =
            generateDeck

        bankBalance =
            (startingBankCash - (numPlayers * 2))
    in
        { initialModel | players = newPlayers, deck = newDeck, bank = bankBalance }


dealAllPlayers : Model -> Model
dealAllPlayers model =
    Actions.recursiveAction 1 Actions.dealCard model
        |> Actions.recursiveAction 1 Actions.dealCard


generateDeck : Deck
generateDeck =
    let
        cards =
            [ Card Duke Alive
            , Card Captain Alive
            , Card Assassin Alive
            , Card Contessa Alive
            , Card Ambassador Alive
            ]

        triple card =
            List.repeat 3 card
    in
        List.map triple cards
            |> List.concat


endTurn : Model -> Model
endTurn model =
    let
        oldID =
            model.currentPlayerID

        newID =
            if oldID == List.length model.players then
                1
            else
                oldID + 1

        players =
            List.map
                (\p ->
                    if p.id == newID then
                        { p | state = DecidingAction }
                    else
                        p
                )
                model.players
    in
        { model | currentPlayerID = newID, players = players }


handleResponse : Response -> PlayerID -> Model -> Model
handleResponse response id model =
    case response of
        Allow ->
            model

        Challenge action ->
            let
                turnID =
                    model.currentPlayerID

                hand =
                    List.foldl
                        (\p hand ->
                            if p.id == turnID then
                                p.hand
                            else
                                hand
                        )
                        []
                        model.players

                isNotBluff =
                    List.any (\card -> NonNeutral card.role == action.neutrality) hand

                players =
                    if isNotBluff then
                        changePlayerState id FlippingCard model.players
                    else
                        changePlayerState turnID FlippingCard model.players
            in
                { model | players = players }

        Block ->
            model
