module Compress.Format.V2 exposing (decoder, encoder)

import Bytes
import Bytes.Decode as BD
import Bytes.Encode as BE
import Time exposing (Posix)


stringEncoder : String -> BE.Encoder
stringEncoder string =
    BE.string string


stringDecoder : Int -> BD.Decoder String
stringDecoder width =
    BD.string width


posixEncoder : Posix -> BE.Encoder
posixEncoder date =
    Time.posixToMillis date // 60000 |> BE.unsignedInt32 Bytes.BE


posixDecoder : BD.Decoder Posix
posixDecoder =
    BD.unsignedInt32 Bytes.BE |> BD.map ((*) 60000 >> Time.millisToPosix)


encoder : ( Posix, String ) -> BE.Encoder
encoder ( date, text ) =
    BE.sequence
        [ posixEncoder date
        , stringEncoder text
        ]


decoder : Int -> BD.Decoder ( Posix, String )
decoder width =
    BD.map2 Tuple.pair posixDecoder (stringDecoder (width - 4))
