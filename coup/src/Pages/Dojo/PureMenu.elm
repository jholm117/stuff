module Pages.Dojo.PureMenu exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Bootstrap.Modal as Modal
import Bootstrap.Button as Button


type alias Context =
    { modalState : Modal.State }


type alias Config msg =
    { modalMsg : Modal.State -> msg }


view : Config msg -> Context -> Html msg
view msg context =
    div []
        [ Modal.config msg.modalMsg
            |> Modal.small
            |> Modal.h3 [] [ text "Welcome to the Dojo" ]
            |> Modal.body
                []
                [ p
                    []
                    [ text "How many opponents?" ]
                ]
            |> Modal.footer []
                [ Button.button
                    [ Button.success
                    , Button.attrs [ onClick <| msg.modalMsg Modal.hiddenState ]
                    ]
                    [ text "Start!" ]
                ]
            |> Modal.view context.modalState
        ]
