module Game.View exposing (..)

import Bootstrap.Button as Button exposing (onClick)
import Bootstrap.ButtonGroup as ButtonGroup
import Bootstrap.Grid as Grid
import Bootstrap.ListGroup as ListGroup
import Game.Actions exposing (..)
import Game.Types exposing (..)
import Html exposing (..)


view : Model -> Html Msg
view model =
    let
        cardView card =
            p [] [ text (roleToString card.role) ]

        deckView deck =
            mapToListGroup
                (List.map cardView deck)

        playerView player =
            Grid.row []
                [ Grid.col []
                    [ div []
                        [ h4 [] [ text ("ID: " ++ (toString player.id)) ]
                        , div [] (List.map cardView player.hand)
                        , p [] [ text ((toString player.wallet) ++ " coins") ]
                        ]
                    ]
                , Grid.col []
                    [ div []
                        [ iView model player ]
                    ]
                ]

        playersView players =
            mapToListGroup
                (List.map playerView players)
    in
        Grid.container []
            [ Grid.row []
                [ Grid.col []
                    [ deckView model.deck ]
                , Grid.col []
                    [ bankView model.bank
                    ]
                , Grid.col []
                    [ playersView model.players ]
                ]
            ]


currentPlayerView : List Action -> Html Msg
currentPlayerView actions =
    let
        header =
            h5 [] [ text "Your Turn!" ]

        button action =
            ButtonGroup.button
                [ Button.outlinePrimary
                , Button.onClick action
                ]
                [ text action.name ]

        buttons =
            ButtonGroup.buttonGroup
                [ ButtonGroup.vertical ]
                (List.map (\a -> button a) actions)
    in
        div []
            [ header
            , div []
                [ buttons ]
            ]
            |> Html.map ActionMsg


iView : Model -> Player -> Html Msg
iView model { hand, wallet, id, state } =
    case state of
        Responding action ->
            respondingView action id

        DecidingAction ->
            currentPlayerView (availableActions model)

        FlippingCard ->
            flipCardView hand id

        Waiting ->
            p [] [ text ("It's " ++ (toString model.currentPlayerID) ++ "'s Turn. Waiting...") ]


respondingView : Action -> PlayerID -> Html Msg
respondingView action id =
    let
        allowButton =
            ButtonGroup.button
                [ Button.outlinePrimary
                , Button.onClick (ResponseMsg Allow id)
                ]
                [ text "Allow" ]

        challengeButton =
            ButtonGroup.button
                [ Button.outlineDanger
                , Button.onClick (ResponseMsg (Challenge action) id)
                ]
                [ text "Challenge" ]

        blockButton =
            ButtonGroup.button
                [ Button.outlineWarning
                , Button.onClick (ResponseMsg Block id)
                ]
                [ text "Block" ]

        buttons =
            case action.counterable of
                Unstoppable ->
                    []

                Blockable ->
                    [ blockButton ]

                BlockableAndChallengeable ->
                    [ blockButton, challengeButton ]

                Challengeable ->
                    [ challengeButton ]
    in
        div
            []
            [ ButtonGroup.buttonGroup
                [ ButtonGroup.vertical ]
                (allowButton :: buttons)
            ]


flipCardView : Hand -> PlayerID -> Html Msg
flipCardView hand id =
    let
        button card =
            ButtonGroup.button
                [ Button.primary
                , Button.onClick (FlipCardMsg card id)
                ]
                [ text (roleToString card.role) ]
    in
        div
            []
            [ ButtonGroup.buttonGroup
                [ ButtonGroup.vertical ]
                (List.map (\c -> button c) hand)
            ]


roleToString : Role -> String
roleToString role =
    case role of
        Ambassador ->
            "Ambassador"

        Captain ->
            "Captain"

        Assassin ->
            "Assassin"

        Contessa ->
            "Contessa"

        Duke ->
            "Duke"

        ERROR ->
            "ERROR"


bankView : Bank -> Html msg
bankView bank =
    div []
        [ u [] [ text "Bank" ]
        , p [] [ text (String.append (toString bank) " coins") ]
        ]


mapToListGroup : List (Html msg) -> Html msg
mapToListGroup list =
    ListGroup.ul
        (List.map
            (\m -> ListGroup.li [] [ m ])
            list
        )
