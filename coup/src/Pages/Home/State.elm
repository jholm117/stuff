module Pages.Home.State exposing (..)

import Pages.Home.Types exposing (..)

-- initalModel : Model
-- initalModel =
--     {
--     ,}

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GoToDojo ->
            ( model, Cmd.none )
