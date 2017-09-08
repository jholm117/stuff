module Game.Types exposing (..)


type Msg
    = UpdateDeckMsg Deck
    | StartGameMsg Int
    | ActionMsg Action
    | ResponseMsg Response PlayerID
    | FlipCardMsg Card PlayerID


type Response
    = Allow
    | Challenge Action
    | Block


type Counterable
    = Blockable
    | Challengeable
    | BlockableAndChallengeable
    | Unstoppable


type ActionType
    = Income
    | ForeignAid
    | Tax
    | Steal
    | Exchange
    | Assassinate
    | Coup


type Condition
    = Cost Coins
    | TakeMoney Target Coins
    | NonCondition


type Target
    = PlayerTarget
    | BankTarget


type Neutrality
    = Neutral
    | NonNeutral Role


type alias Action =
    { actionType : ActionType
    , name : String
    , counterable : Counterable
    , condition : Condition
    , neutrality : Neutrality
    }


type alias Player =
    { hand : Hand
    , wallet : Coins
    , id : PlayerID
    , state : TurnState
    }


type alias Card =
    { role : Role
    , status : Status
    }


type TurnState
    = DecidingAction
    | Responding Action
    | Waiting
    | FlippingCard


type Status
    = Alive
    | Dead


type Role
    = Duke
    | Captain
    | Assassin
    | Contessa
    | Ambassador
    | ERROR


errorCard : Card
errorCard =
    Card ERROR Dead


type alias Model =
    { players : Players
    , deck : Deck
    , currentPlayerID : PlayerID
    , bank : Bank
    }


type alias PlayerID =
    Int


type alias Coins =
    Int


type alias Hand =
    List Card


type alias Players =
    List Player


type alias Deck =
    List Card


type alias Bank =
    Coins
