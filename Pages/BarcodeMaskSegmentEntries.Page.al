page 63001 "Barcode Mask Segment Entries"
{
    // version MER1.0

    ApplicationArea = All;
    UsageCategory = Documents;
    Caption = 'Barcode Mask Segment Entries';
    PageType = CardPart;
    SourceTable = "Barcode Mask Segment";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(SegmentNo; "Segment No")
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        TypeOnAfterValidate;
                    end;
                }
                field(Length; Length)
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        LengthOnAfterValidate;
                    end;
                }
                field(Char; Char)
                {
                    ApplicationArea = All;
                    Caption = 'Char';
                    Editable = CharEditable;

                    trigger OnValidate()
                    begin
                        CharOnAfterValidate;
                    end;
                }
                field(Decimals; Decimals)
                {
                    ApplicationArea = All;
                }
            }
            field(MaskStr2; MaskStr)
            {
                ApplicationArea = All;
                Editable = false;
                ShowCaption = false;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        if Type = Type::"Any No." then
            CharEditable := true
        else
            CharEditable := false;
        if MaskStr = '' then
            UpdateMask;
    end;

    trigger OnOpenPage()
    begin
        if "Mask Entry No." <> 0 then
            UpdateMask;
    end;

    var
        BarcMask: Record "Barcode Mask";
        MaskChar: Record "Barcode Mask Character";
        MaskStr: Text[50];
        [InDataSet]
        CharEditable: Boolean;

    procedure UpdateMask()
    begin
        BarcMask.Get("Mask Entry No.");
        BarcMask.UpdateMask;
        BarcMask.CalcFields(Length);
        MaskStr := CopyStr(BarcMask.Mask + ' (' + Format(StrLen(BarcMask.Prefix) + BarcMask.Length) + ')', 1, 50);
    end;

    local procedure TypeOnAfterValidate()
    begin
        MaskChar.Get(Type);
        Char := MaskChar.Character;
        CurrPage.SaveRecord;
        UpdateMask;
    end;

    local procedure LengthOnAfterValidate()
    begin
        CurrPage.SaveRecord;
        UpdateMask;
    end;

    local procedure CharOnAfterValidate()
    begin
        if "Mask Entry No." <> 0 then begin
            CurrPage.SaveRecord;
            UpdateMask;
        end;
    end;

    local procedure TypeOnActivate()
    begin
        UpdateMask;
    end;
}

