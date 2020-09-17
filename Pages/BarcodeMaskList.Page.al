page 63002 "Barcode Mask List"
{
    // version MER1.0

    UsageCategory = Lists;
    Caption = 'Barcode Mask List';
    DelayedInsert = true;
    Editable = false;
    PageType = List;
    SourceTable = "Barcode Mask";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Mask; Mask)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(NumberSeries; "Number Series")
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

