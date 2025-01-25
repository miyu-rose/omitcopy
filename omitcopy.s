;=========================================================================================
;
; OmitCopy version 1.00  by Hau & みゆ (miyu rose)
;
;        Programmer        みゆ (miyu rose)
;                          X68KBBS：X68K0001
;                          Twitter：@arith_rose
;
;        Special Adviser   はう (Hau) さま
;                 Tester   X68KBBS：X68K0024
;                          Twitter：@Hau_oli
;
;=========================================================================================

    .cpu        68000

    .include    doscall.mac

;=========================================================================================

    .text
    .even

;=========================================================================================
; メインルーチン
;-----------------------------------------------------------------------------------------
main:

    lea.l   mysp,sp                             ; sp : 自前スタックエリアの先頭アドレス

;-----------------------------------------------------------------------------------------

title:
    move.l  a0,-(sp)                            ; a0 を退避

    move.w  #$0006,d0                           ; $6 = $2(黄色) + $4(太字)
    lea.l   mes_title,a0                        ; タイトル
    bsr     cprint                              ; 表示

    move.w  #$0007,d0                           ; $7 = $3(白)   + $4(太字)
    lea.l   mes_version,a0                      ; バージョン
    bsr     cprint                              ; 表示

    move.w  #$0003,d0                           ; $3(白)
    lea.l   mes_by,a0                           ; by
    bsr     cprint                              ; 表示

    move.w  #$0007,d0                           ; $7 = $3(白)   + $4(太字)
    lea.l   mes_author,a0                       ; 作者
    bsr     cprint                              ; 表示

    move.w  #$0003,d0                           ; $3(白)
    lea.l   mes_nul,a0                          ; 空文字列
    bsr     cprint                              ; 表示

    movea.l (sp)+,a0                            ; a0 を復元

;-----------------------------------------------------------------------------------------
arg_begin:

    addq.l  #1,a2                               ; 引数のサイズは無視

arg_loop:
    move.b  (a2)+,d0                            ; d0 : 引数文字列から 1 Byte pop

    cmpi.b  #$00,d0                             ; 引数を終端と比較
    beq     arg_end                             ;  一致してたら終了
    cmpi.b  #' ',d0                             ; 引数をスペースと比較
    beq     arg_loop                            ;  一致してたらループ(スキップ)

    cmpi.b  #'-',d0                             ; '-'(プレフィクスその１) と比較
    beq     arg_option                          ;  一致してたらオプション処理へ
    cmpi.b  #'/',d0                             ; '/'(プレフィクスその２) と比較
    beq     arg_option                          ;  一致してたらオプション処理へ

    bra     arg_help                            ; 引数がプレフィクスではないのでヘルプへ

arg_option:
    move.b  (a2)+,d0                            ; d0 : 引数文字列から 1 Byte pop
    cmpi.b  #$00,d0                             ; 引数と終端を比較
    beq     arg_end                             ;  一致してたら終了

    andi.b  #$df,d0                             ; bit5 を下げる = 大文字化 
                                                ;  ('a'～'z' → 'A'～'Z')
    cmpi.b  #'R',d0                             ; 'R' と比較
    beq     arg_release                         ;  一致してたら常駐解除指定へ

arg_help:
    pea.l   mes_help                            ; ヘルプメッセージ
    DOS     _PRINT
    addq.l  #4,sp

    DOS     _EXIT                               ; 終了

arg_release:
    move.b  #$01,flg_release                    ; 常駐解除指定フラグを立てる
    bra     arg_loop                            ; 引数処理をループ

arg_end:
;-----------------------------------------------------------------------------------------

prepare:
    movea.l #$000000b0,a1                       ; a1 : 割込ベクタ格納アドレス
    move.l  #'OMIT',d0                          ; d0 : 常駐マーカー上位ロングワード
    move.l  #'COPY',d1                          ; d1 : 常駐マーカー下位ロングワード
    bsr     TSR_prepare                         ; 常駐準備

    tst.b   flg_release                         ; 常駐解除指定フラグをチェック
    bne     release                             ;  立っていたら常駐解除へ

;-----------------------------------------------------------------------------------------

resident:
    lea.l   residented,a5                       ; a5 : 常駐完了時のコールバックアドレス
    bsr     TSR_resident                        ; 常駐

    pea.l   mes_residented_already              ; 「既に常駐してますよ」
    DOS     _PRINT                              ; 表示
    addq.l  #4,sp

    DOS     _EXIT                               ; おしまい

residented:
    pea.l   mes_residented                      ; 「常駐しました」
    DOS     _PRINT                              ; 表示
    addq.l  #4,sp

    rts

;-----------------------------------------------------------------------------------------

release:
    bsr     TSR_release                         ; 常駐解除
    beq     @@f                                 ; 常駐解除成功したので次へ
    bmi     @f

    pea.l   mes_not_resident                    ; 「常駐してません」
    DOS     _PRINT                              ; 表示
    addq.l  #4,sp

    DOS     _EXIT                               ; おしまい

@@:
    pea.l   mes_cannot_release                  ; 「常駐解除できません」
    DOS     _PRINT                              ; 表示
    addq.l  #4,sp

    DOS     _EXIT                               ; おしまい

@@:
    pea.l   mes_released                        ; 「常駐解除しました」
    DOS     _PRINT
    addq.l  #4,sp

    DOS     _EXIT                               ; おしまい

;=========================================================================================

cprint:
    move.w  d0,-(sp)                            ; 文字属性
    move.w  #$0002,-(sp)                        ; 文字属性の設定ﾓｰﾄﾞ
    DOS     _CONCTRL
    addq.l  #4,sp

    pea.l   (a0)                                ; 文字列のポインタ
    DOS     _PRINT
    addq.l  #4,sp

    rts

;=========================================================================================

    .data
    .even

;-----------------------------------------------------------------------------------------

mes_title:
    .dc.b   'OmitCopy ',$00
mes_version:
    .dc.b   $f3,'v',$f3,'e',$f3,'r',$f3,'s',$f3,'i',$f3,'o',$f3,'n',$f3,' ',$f3,'1',$f3,'.',$f3,'0',$f3,'0',$00
mes_by:
    .dc.b   ' ',$f3,'b',$f3,'y ',$00
mes_author:
    .dc.b   'Hau & みゆ (miyu rose)'
mes_crlf:
    .dc.b   $0d,$0a
mes_nul:
    .dc.b   $00

mes_help:
    .dc.b   '-R で常駐解除しまーす',$0d,$0a,$0d,$0a,$00

mes_error:
    .dc.b   '再起動してから改めてお試しくださいませ！',$0d,$0a,$0d,$0a,$00

mes_residented:
    .dc.b   '常駐しました！',$0d,$0a,$0d,$0a,$00
mes_residented_already:
    .dc.b   '既に常駐してますよ！',$0d,$0a,$0d,$0a,$00
mes_not_resident:
    .dc.b   '常駐してないですよ～！',$0d,$0a,$0d,$0a,$00
mes_cannot_release:
    .dc.b   '常駐解除できませんでした！',$0d,$0a,$0d,$0a,$00
mes_released:
    .dc.b   '常駐解除しました！',$0d,$0a,$0d,$0a,$00

;=========================================================================================

    .bss
    .even

;-----------------------------------------------------------------------------------------

flg_release:
    .dc.b      $00                             ; 常駐解除フラグ

;=========================================================================================

    .stack
    .even

mysp_last:
    .ds.l      256
mysp:

    .end       main

;=========================================================================================
