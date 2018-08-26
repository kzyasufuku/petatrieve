# petatrieve  

peta-trieve

expecting like:

    $ src/retriever.pl   misc/retfiles.json  misc/retwords.json
    search word(s): '山本' '浩太郎'
    ==== files/inf_hokkaido.txt ===============
    ==== files/inf_sendai.txt =================
    ==== files/inf_tochigi.txt ================
    8065) 12 Aug 山本 浩太郎 チーム三条
    ==== files/nishi-nihon/kagawa.txt =========
    14092) 支援/山本浩太郎 4days
    ===========================================
    $

ex. upd2: for Windows

    > src\retriever.pl misc\retfiles.json  misc\retwords.json
    *** MSWin32 Start retriever.pl 'misc\retfiles.json misc\retwords.json' ***
    retrieve word(s): '山本' '浩太郎'

    ==== misc/inf_foo.txt =======================================
    1) cccccccc山本浩太郎ccccccccc
    3) 山本  浩太郎 eeeeeeeee
    ==== misc/inf_narrow.txt ====================================
    ==== misc/infWide.txt =======================================
    1) 3 3 山本 浩太郎- - - - - 333
    =============================================================

    >
