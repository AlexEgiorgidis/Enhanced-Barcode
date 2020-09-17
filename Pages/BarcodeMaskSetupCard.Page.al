page 63003 "Barcode Mask Setup Card"
{
    // version MER1.0

    ApplicationArea = All;
    UsageCategory = Documents;
    Caption = 'Barcode Mask Setup Card';
    DataCaptionFields = Description;
    PageType = Card;
    SourceTable = "Barcode Mask";

    layout
    {
        area(content)
        {
            group(General)
            {
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Prefix; Prefix)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        Modify;
                        CurrPage.Segments.Page.UpdateMask;
                    end;
                }
                field(NumberSeries; "Number Series")
                {
                    ApplicationArea = All;
                }
                field(Symbology; Symbology)
                {
                    ApplicationArea = All;
                }
            }
            part(Segments; "Barcode Mask Segment Entries")
            {
                ApplicationArea = All;
                SubPageLink = "Mask Entry No." = field("Entry No.");
            }
        }
    }

    actions
    {
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        xMask: Code[22];
    begin
        xMask := Mask;
        UpdateMask;
        if Mask <> xMask then
            CurrPage.SaveRecord;
    end;
}

