module Pages.Dojo.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Pages.Dojo.Types exposing (..)
import Bootstrap.Grid as Grid
import Bootstrap.Card as Card
import Game.View as Game
import Pages.Dojo.Menu as Menu


dojoPage : Model -> Html Msg
dojoPage model =
    Grid.container
        []
        [ Grid.row
            []
            [ Grid.col
                []
                []
            , Grid.col
                []
                [ title ]
            , Grid.col
                []
                []
            ]
        , Grid.row
            []
            [ Grid.col
                []
                []
            , Grid.col
                []
                [ Menu.view model.menu
                    |> Html.map MenuMsg
                ]
            , Grid.col
                []
                []
            ]
        , Grid.row
            []
            [ Grid.col
                []
                []
            , Grid.col
                []
                []
            , Grid.col
                []
                []
            ]
        , Game.view model.game
            |> Html.map GameMsg
        ]


title : Html msg
title =
    div
        [ class "page-header" ]
        [ h1
            []
            [ text "Dojo" ]
        ]


cards : Html msg
cards =
    Card.config [ Card.info, Card.attrs [ class "" ] ]
        |> Card.block []
            [ Card.text [] [ text "HELLO" ] ]
        |> Card.view
