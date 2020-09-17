pageextension 63000 "Item Card" extends "Item Card"
{
    layout
    {
        addlast(Item)
        {
            field("Barcode Mask"; "Barcode Mask")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Barcode Mask';
            }
        }
    }
    actions
    {
        addafter("&Create Stockkeeping Unit")
        {
            action("Create Barcodes")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Create Barcodes';
                image = BarCode;

                trigger OnAction()
                var
                    Item: Record Item;
                begin
                    Item := Rec;
                    Item.SETRECFILTER;
                    REPORT.RUN(REPORT::"Create Barcode On Mass", TRUE, FALSE, Item);
                end;
            }
        }
    }
}