pageextension 63000 "Item Card" extends "Item Card"
{
    layout
    {
        addafter("Item Category Code")
        {
            field("Barcode Mask"; "Barcode Mask")
            {
                ApplicationArea = all;
            }
        }
    }
    actions
    {
        addafter("&Create Stockkeeping Unit")
        {
            action("Create Barcodes")
            {
                ApplicationArea = All;
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