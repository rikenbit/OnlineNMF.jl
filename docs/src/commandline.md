# OnlineNMF.jl (Command line tool)

All functions can be performed as command line tool in shell window and same options in [OnlineNMF.jl (Julia API)](@ref) are available.

After installation of `OnlineNMF.jl`, command line tools are saved at `YOUR_HOME_DIR/.julia/v1.x/OnlineNMF/bin/`.

The functions can be performed as below.

## Non-negative Matrix Factorization (NMF)
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlineNMF/bin/nmf \
--input Data.zst \
--outdir OUTDIR \
--alpha 1 \
--beta 2 \
--graphv 1.0e-8 \
--l1u 1.0e-8 \
--l1v 1.0e-8 \
--l2u 1.0e-8 \
--l2v 1.0e-8 \
--dim 3 \
--numepoch 5 \
--chunksize 1 \
--algorithm frobenius \
--lower 0 \
--upper 1.0f+38 \
--initU U.csv \
--initV V.csv \
--initL L.csv \
--logdir OUTDIR
```

## Discretized Non-negative Matrix Factorization (DNMF)
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlineNMF/bin/dnmf \
--input Data.zst \
--outdir OUTDIR \
--beta 2 \
--binu 1.0e-8 \
--binv 1.0e-8 \
--teru 1.0e-8 \
--terv 1.0e-8 \
--graphv 1.0e-8 \
--l1u 1.0e-8 \
--l1v 1.0e-8 \
--l2u 1.0e-8 \
--l2v 1.0e-8 \
--dim 3 \
--numepoch 5 \
--chunksize 1 \
--lower 0 \
--upper 1.0f+38 \
--initU U.csv \
--initV V.csv \
--initL L.csv \
--logdir OUTDIR
```

## Sparse Non-negative Matrix Factorization (SNMF)
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlineNMF/bin/sparse_nmf \
--input Data.mtx.zst \
--outdir OUTDIR \
--alpha 1 \
--beta 2 \
--graphv 1.0e-8 \
--l1u 1.0e-8 \
--l1v 1.0e-8 \
--l2u 1.0e-8 \
--l2v 1.0e-8 \
--dim 3 \
--numepoch 5 \
--chunksize 1 \
--algorithm frobenius \
--lower 0 \
--upper 1.0f+38 \
--initU U.csv \
--initV V.csv \
--initL L.csv \
--logdir OUTDIR
```

## Sparse Discretized Non-negative Matrix Factorization (SDNMF)
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlineNMF/bin/sparse_dnmf \
--input Data.mtx.zst \
--outdir OUTDIR \
--beta 2 \
--binu 1.0e-8 \
--binv 1.0e-8 \
--teru 1.0e-8 \
--terv 1.0e-8 \
--graphv 1.0e-8 \
--l1u 1.0e-8 \
--l1v 1.0e-8 \
--l2u 1.0e-8 \
--l2v 1.0e-8 \
--dim 3 \
--numepoch 5 \
--chunksize 1 \
--lower 0 \
--upper 1.0f+38 \
--initU U.csv \
--initV V.csv \
--initL L.csv \
--logdir OUTDIR
```

## Binary COO Non-negative Matrix Factorization (BinCOONMF)
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlineNMF/bin/bincoo_nmf \
--input Data.bincoo.zst \
--outdir OUTDIR \
--alpha 1 \
--beta 2 \
--graphv 1.0e-8 \
--l1u 1.0e-8 \
--l1v 1.0e-8 \
--l2u 1.0e-8 \
--l2v 1.0e-8 \
--dim 3 \
--numepoch 5 \
--chunksize 1 \
--algorithm frobenius \
--lower 0 \
--upper 1.0f+38 \
--initU U.csv \
--initV V.csv \
--initL L.csv \
--logdir OUTDIR
```

## Binary COO Discretized Non-negative Matrix Factorization (BinCOODNMF)
```bash
shell> julia YOUR_HOME_DIR/.julia/v1.x/OnlineNMF/bin/bincoo_dnmf \
--input Data.bincoo.zst \
--outdir OUTDIR \
--beta 2 \
--binu 1.0e-8 \
--binv 1.0e-8 \
--teru 1.0e-8 \
--terv 1.0e-8 \
--graphv 1.0e-8 \
--l1u 1.0e-8 \
--l1v 1.0e-8 \
--l2u 1.0e-8 \
--l2v 1.0e-8 \
--dim 3 \
--numepoch 5 \
--chunksize 1 \
--lower 0 \
--upper 1.0f+38 \
--initU U.csv \
--initV V.csv \
--initL L.csv \
--logdir OUTDIR
```
