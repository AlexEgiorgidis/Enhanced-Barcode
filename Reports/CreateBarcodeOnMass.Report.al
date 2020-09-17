report 63000 "Create Barcode On Mass"
{
    // version MER1.0

    // //Doc RAN-294 TA 20.04.18 All Mass Create to be run on the scheduler

    ApplicationArea = All;
    UsageCategory = Documents;
    ProcessingOnly = true;

    dataset
    {
        dataitem(DataItem10014501; Item)
        {
            RequestFilterFields = "No.", "Item Category Code";
            dataitem(DataItem10014500; "Item Variant")
            {
                DataItemLink = "Item No." = field("No.");

                trigger OnAfterGetRecord()
                begin
                    if GuiAllowed then
                        Window.Update(2, Code);

                    Clear(BarcodeMgmt);
                    Clear(ItemCrossReference);
                    ItemCrossReference.SetRange("Item No.", "Item No.");
                    ItemCrossReference.SetRange("Variant Code", Code);
                    ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
                    ItemCrossReference.SetRange("Internal Barcode", true);
                    if not ItemCrossReference.FindFirst then begin
                        ItemCrossReference.Init;
                        ItemCrossReference.Validate("Item No.", "Item No.");
                        ItemCrossReference.Validate("Variant Code", Code);
                        ItemCrossReference.Validate("Unit of Measure", DataItem10014501."Base Unit of Measure");
                        ItemCrossReference.Validate("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
                        ItemCrossReference."Cross-Reference No." := BarcodeMgmt.ConstructBarcodeFromMask(BarcodeMask);
                        ItemCrossReference.Description := Description;
                        ItemCrossReference."Internal Barcode" := true;
                        if ItemCrossReference.Insert(true) then;
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            begin
                VariantCounter := VariantCounter + 1;
                if GuiAllowed then
                    Window.Update(1, Round((VariantCounter / VariantCount) * 10000, 1));

                ItemVariant2.SetRange("Item No.", "No.");
                if not ItemVariant2.FindFirst then begin
                    Clear(BarcodeMgmt);
                    Clear(ItemCrossReference);
                    ItemCrossReference.SetRange("Item No.", "No.");
                    ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
                    ItemCrossReference.SetRange("Internal Barcode", true);
                    if not ItemCrossReference.FindFirst then begin
                        ItemCrossReference.Init;
                        ItemCrossReference.Validate("Item No.", "No.");
                        ItemCrossReference.Validate("Unit of Measure", "Base Unit of Measure");
                        ItemCrossReference.Validate("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
                        ItemCrossReference."Cross-Reference No." := BarcodeMgmt.ConstructBarcodeFromMask(BarcodeMask);
                        ItemCrossReference.Description := Description;
                        ItemCrossReference."Internal Barcode" := true;
                        if ItemCrossReference.Insert(true) then;
                    end;
                end;
            end;

            trigger OnPreDataItem()
            begin
                if SelectedBarcodeMask = '' then
                    Error(QIX001);

                VariantCount := DataItem10014501.Count;
                if GuiAllowed then begin
                    Window.Open('Item              @1@@@@@@@@@@@@@@@@@@@@@\' +
                                            'Item Variant      #2#####################');
                end;
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Options)
                {
                    field(SelectedBarcodeMask2; SelectedBarcodeMask)
                    {
                        ApplicationArea = All;
                        Caption = 'Select Barcode Mask';
                        TableRelation = "Barcode Mask";

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            Clear(Masks);
                            Masks.LookupMode(true);
                            Masks.SetTableView(BarcodeMask);
                            if Masks.RunModal = Action::LookupOK then begin
                                Masks.GetRecord(BarcodeMask);
                                SelectedBarcodeMask := BarcodeMask.Mask;
                            end;
                        end;
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        ItemVariant2: Record "Item Variant";
        ItemCrossReference: Record "Item Cross Reference";
        BarcodeMask: Record "Barcode Mask";
        BarcodeMgmt: Codeunit "Barcode Management";
        Masks: Page "Barcode Mask List";
        Window: Dialog;
        SelectedBarcodeMask: Code[20];
        VariantCount: Integer;
        VariantCounter: Integer;
        QIX001: Label 'Please Select a Barcode Mask';

    procedure SetBarcodeMask(pBarcodeMask: Code[20])
    begin
        SelectedBarcodeMask := pBarcodeMask;
    end;
}

