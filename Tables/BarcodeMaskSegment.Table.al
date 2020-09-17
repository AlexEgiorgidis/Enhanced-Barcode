table 63001 "Barcode Mask Segment"
{
    // version MER1.0

    DataClassification = CustomerContent;
    Caption = 'Barcode Mask Segment';

    fields
    {
        field(10; "Mask Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Mask Entry No.';
        }
        field(20; "Segment No"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Segment No';
            NotBlank = true;
        }
        field(25; Length; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Length';
            DecimalPlaces = 0 : 0;
            MaxValue = 20;
            MinValue = 0;
        }
        field(30; Type; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
            OptionCaption = 'Item No.,Any No.,Check Digit,Number Series';
            OptionMembers = "Item No.","Any No.","Check Digit","Number Series";

            trigger OnValidate()
            begin
                MaskChar.Get(Type);
                Char := MaskChar.Character;
            end;
        }
        field(35; Decimals; Integer)
        {
            DataClassification = CustomerContent;
            BlankNumbers = BlankZero;
            Caption = 'Decimals';
            MaxValue = 3;
            MinValue = 0;
        }
        field(40; Char; Code[1])
        {
            DataClassification = CustomerContent;
            Caption = 'Char';
        }
    }

    keys
    {
        key(Key1; "Mask Entry No.", "Segment No")
        {
            Clustered = true;
            SumIndexFields = Length;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        MaskChar.Get(Type);
        Char := MaskChar.Character;
    end;

    trigger OnModify()
    begin
        MaskChar.Get(Type);
        Char := MaskChar.Character;
    end;

    var
        MaskChar: Record "Barcode Mask Character";
}

