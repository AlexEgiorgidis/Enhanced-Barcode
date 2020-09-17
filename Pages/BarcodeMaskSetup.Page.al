page 63004 "Barcode Mask Setup"
{
    // version MER1.0

    ApplicationArea = All;
    Caption = 'Barcode Mask Setup';
    CardPageID = "Barcode Mask Setup Card";
    PageType = List;
    PromotedActionCategories = 'New';
    SourceTable = "Barcode Mask";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field(Mask; Mask)
                {
                    ApplicationArea = All;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        MaskCard: Page 63003;
                        tmpRec: Record "Barcode Mask";
                    begin
                        Commit;
                        tmpRec.SetRange("Entry No.", "Entry No.");
                        MaskCard.SetTableView(tmpRec);
                        MaskCard.RunModal;
                        Rec.Get("Entry No.");
                        if Prefix = '' then begin
                            Error(Text000);
                            Mask := '';
                        end;
                        UpdateMask;
                        CurrPage.Update;
                    end;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Symbology; Symbology)
                {
                    ApplicationArea = All;
                }
                field(Length; Length + StrLen(Prefix))
                {
                    ApplicationArea = All;
                    Caption = 'Length';
                    DecimalPlaces = 0 : 0;
                    Editable = false;
                }
                field(NumberSeries; "Number Series")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = All;
                Visible = true;
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        CalcFields(Length);
        Length43STRLENPrefixOnFormat;
    end;

    var
        Text000: Label 'Prefix is missing';

    local procedure Length43STRLENPrefixOnFormat()
    begin
        if GetRefLength <> 0 then
            if GetRefLength <> (Length + StrLen(Prefix)) then;
    end;
}

