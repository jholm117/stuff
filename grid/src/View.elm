module View exposing (..)

import Bootstrap.Button as Button exposing (onClick)
import Grid
import Html exposing (..)
import Types exposing (..)


view : Model -> Html Msg
view { player, grid } =
    div []
        [ Grid.view grid
        , spawnButton player
        ]


spawnButton : Character -> Html Msg
spawnButton player =
    case player.status of
        Alive coordinate ->
            b [] [ text "Good Luck" ]

        Dead ->
            Button.button
                [ Button.primary
                , onClick <| SpawnMsg True
                ]
                [ text "Spawn" ]
