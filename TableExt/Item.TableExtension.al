tableextension 63000 Item extends Item
{

    fields
    {
        field(63000; "Barcode Mask"; Code[20])
        {
            Caption = 'Barcode Mask';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                BarcodeMmgt: Codeunit "Barcode Management";
            Begin
                IF "Barcode Mask" <> '' THEN
                    BarcodeMmgt.CheckItemMask("Barcode Mask", Rec);
            End;

            trigger OnLookup()
            var
                BarcodeMask: Record "Barcode Mask";
            begin
                BarcodeMask.RESET;
                IF PAGE.RUNMODAL(PAGE::"Barcode Mask List", BarcodeMask) = ACTION::LookupOK THEN
                    VALIDATE("Barcode Mask", BarcodeMask.Mask);
            end;
        }
    }
}