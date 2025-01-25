;=========================================================================================
;
; OmitCopy version 1.00  by Hau & �݂� (miyu rose)
;
;        Programmer        �݂� (miyu rose)
;                          X68KBBS�FX68K0001
;                          Twitter�F@arith_rose
;
;        Special Adviser   �͂� (Hau) ����
;                 Tester   X68KBBS�FX68K0024
;                          Twitter�F@Hau_oli
;
;=========================================================================================

    .cpu        68000

    .include    doscall.mac

;=========================================================================================

    .text
    .even

;=========================================================================================
; ���C�����[�`��
;-----------------------------------------------------------------------------------------
main:

    lea.l   mysp,sp                             ; sp : ���O�X�^�b�N�G���A�̐擪�A�h���X

;-----------------------------------------------------------------------------------------

title:
    move.l  a0,-(sp)                            ; a0 ��ޔ�

    move.w  #$0006,d0                           ; $6 = $2(���F) + $4(����)
    lea.l   mes_title,a0                        ; �^�C�g��
    bsr     cprint                              ; �\��

    move.w  #$0007,d0                           ; $7 = $3(��)   + $4(����)
    lea.l   mes_version,a0                      ; �o�[�W����
    bsr     cprint                              ; �\��

    move.w  #$0003,d0                           ; $3(��)
    lea.l   mes_by,a0                           ; by
    bsr     cprint                              ; �\��

    move.w  #$0007,d0                           ; $7 = $3(��)   + $4(����)
    lea.l   mes_author,a0                       ; ���
    bsr     cprint                              ; �\��

    move.w  #$0003,d0                           ; $3(��)
    lea.l   mes_nul,a0                          ; �󕶎���
    bsr     cprint                              ; �\��

    movea.l (sp)+,a0                            ; a0 �𕜌�

;-----------------------------------------------------------------------------------------
arg_begin:

    addq.l  #1,a2                               ; �����̃T�C�Y�͖���

arg_loop:
    move.b  (a2)+,d0                            ; d0 : ���������񂩂� 1 Byte pop

    cmpi.b  #$00,d0                             ; �������I�[�Ɣ�r
    beq     arg_end                             ;  ��v���Ă���I��
    cmpi.b  #' ',d0                             ; �������X�y�[�X�Ɣ�r
    beq     arg_loop                            ;  ��v���Ă��烋�[�v(�X�L�b�v)

    cmpi.b  #'-',d0                             ; '-'(�v���t�B�N�X���̂P) �Ɣ�r
    beq     arg_option                          ;  ��v���Ă���I�v�V����������
    cmpi.b  #'/',d0                             ; '/'(�v���t�B�N�X���̂Q) �Ɣ�r
    beq     arg_option                          ;  ��v���Ă���I�v�V����������

    bra     arg_help                            ; �������v���t�B�N�X�ł͂Ȃ��̂Ńw���v��

arg_option:
    move.b  (a2)+,d0                            ; d0 : ���������񂩂� 1 Byte pop
    cmpi.b  #$00,d0                             ; �����ƏI�[���r
    beq     arg_end                             ;  ��v���Ă���I��

    andi.b  #$df,d0                             ; bit5 �������� = �啶���� 
                                                ;  ('a'�`'z' �� 'A'�`'Z')
    cmpi.b  #'R',d0                             ; 'R' �Ɣ�r
    beq     arg_release                         ;  ��v���Ă���풓�����w���

arg_help:
    pea.l   mes_help                            ; �w���v���b�Z�[�W
    DOS     _PRINT
    addq.l  #4,sp

    DOS     _EXIT                               ; �I��

arg_release:
    move.b  #$01,flg_release                    ; �풓�����w��t���O�𗧂Ă�
    bra     arg_loop                            ; �������������[�v

arg_end:
;-----------------------------------------------------------------------------------------

prepare:
    movea.l #$000000b0,a1                       ; a1 : �����x�N�^�i�[�A�h���X
    move.l  #'OMIT',d0                          ; d0 : �풓�}�[�J�[��ʃ����O���[�h
    move.l  #'COPY',d1                          ; d1 : �풓�}�[�J�[���ʃ����O���[�h
    bsr     TSR_prepare                         ; �풓����

    tst.b   flg_release                         ; �풓�����w��t���O���`�F�b�N
    bne     release                             ;  �����Ă�����풓������

;-----------------------------------------------------------------------------------------

resident:
    lea.l   residented,a5                       ; a5 : �풓�������̃R�[���o�b�N�A�h���X
    bsr     TSR_resident                        ; �풓

    pea.l   mes_residented_already              ; �u���ɏ풓���Ă܂���v
    DOS     _PRINT                              ; �\��
    addq.l  #4,sp

    DOS     _EXIT                               ; �����܂�

residented:
    pea.l   mes_residented                      ; �u�풓���܂����v
    DOS     _PRINT                              ; �\��
    addq.l  #4,sp

    rts

;-----------------------------------------------------------------------------------------

release:
    bsr     TSR_release                         ; �풓����
    beq     @@f                                 ; �풓�������������̂Ŏ���
    bmi     @f

    pea.l   mes_not_resident                    ; �u�풓���Ă܂���v
    DOS     _PRINT                              ; �\��
    addq.l  #4,sp

    DOS     _EXIT                               ; �����܂�

@@:
    pea.l   mes_cannot_release                  ; �u�풓�����ł��܂���v
    DOS     _PRINT                              ; �\��
    addq.l  #4,sp

    DOS     _EXIT                               ; �����܂�

@@:
    pea.l   mes_released                        ; �u�풓�������܂����v
    DOS     _PRINT
    addq.l  #4,sp

    DOS     _EXIT                               ; �����܂�

;=========================================================================================

cprint:
    move.w  d0,-(sp)                            ; ��������
    move.w  #$0002,-(sp)                        ; ���������̐ݒ�Ӱ��
    DOS     _CONCTRL
    addq.l  #4,sp

    pea.l   (a0)                                ; ������̃|�C���^
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
    .dc.b   'Hau & �݂� (miyu rose)'
mes_crlf:
    .dc.b   $0d,$0a
mes_nul:
    .dc.b   $00

mes_help:
    .dc.b   '-R �ŏ풓�������܁[��',$0d,$0a,$0d,$0a,$00

mes_error:
    .dc.b   '�ċN�����Ă�����߂Ă��������������܂��I',$0d,$0a,$0d,$0a,$00

mes_residented:
    .dc.b   '�풓���܂����I',$0d,$0a,$0d,$0a,$00
mes_residented_already:
    .dc.b   '���ɏ풓���Ă܂���I',$0d,$0a,$0d,$0a,$00
mes_not_resident:
    .dc.b   '�풓���ĂȂ��ł���`�I',$0d,$0a,$0d,$0a,$00
mes_cannot_release:
    .dc.b   '�풓�����ł��܂���ł����I',$0d,$0a,$0d,$0a,$00
mes_released:
    .dc.b   '�풓�������܂����I',$0d,$0a,$0d,$0a,$00

;=========================================================================================

    .bss
    .even

;-----------------------------------------------------------------------------------------

flg_release:
    .dc.b      $00                             ; �풓�����t���O

;=========================================================================================

    .stack
    .even

mysp_last:
    .ds.l      256
mysp:

    .end       main

;=========================================================================================
