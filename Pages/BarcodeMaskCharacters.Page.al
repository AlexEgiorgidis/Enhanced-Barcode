page 63000 "Barcode Mask Characters"
{
    // version MER1.0

    ApplicationArea = All;
    Caption = 'Barcode Mask Characters';
    PageType = List;
    SourceTable = "Barcode Mask Character";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(CharacterType; "Character Type")
                {
                    ApplicationArea = All;
                }
                field(Character; Character)
                {
                    ApplicationArea = All;
                }
                field(Comment; Comment)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

