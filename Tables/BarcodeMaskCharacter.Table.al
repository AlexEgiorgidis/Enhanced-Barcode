table 63002 "Barcode Mask Character"
{
    // version MER1.0

    DataClassification = CustomerContent;
    Caption = 'Barcode Mask Character';

    fields
    {
        field(1; "Character Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Character Type';
            OptionCaption = 'Item No.,Any No.,Check Digit,Number Series';
            OptionMembers = "Item No.","Any No.","Check Digit","Number Series";
        }
        field(2; Character; Text[1])
        {
            DataClassification = CustomerContent;
            Caption = 'Character';

            trigger OnValidate()
            begin
                if not (Character in ['A' .. 'Z']) then
                    Error(Text002);
                BarcMaskChar.SetCurrentKey(Character);
                BarcMaskChar.SetFilter("Character Type", '<>%1', "Character Type");
                BarcMaskChar.SetRange(Character, Character);
                if BarcMaskChar.Find('-') then
                    Error(Text003,
                                FieldCaption(Character), Character, FieldCaption("Character Type"), Format(BarcMaskChar."Character Type"));
            end;
        }
        field(3; Comment; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Comment';
        }
    }

    keys
    {
        key(Key1; "Character Type")
        {
            Clustered = true;
        }
        key(Key2; Character)
        {
        }
    }

    fieldgroups
    {
    }

    var
        BarcMaskChar: Record "Barcode Mask Character";
        Text002: Label '%1 must be in the range from A to Z.';
        Text003: Label '%1 %2 is already assigned to %3 %4.';
}

