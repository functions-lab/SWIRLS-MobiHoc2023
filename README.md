# MobiHoc'23 SWIRLS

### Step 1: Unzip Data

Unzip `Data.zip` for all the received Wi-Fi packet waveforms with 

1. Different low sampling rates $f_s$ and their corresponding carrier frequency distances $\Delta f$;
2. Different SNR levels.

### Step 2: Perform SWIRLS

In MATLAB, run `main_LSIG.m` to decode the transmission time bits in `LSIG`, and run `main_HTSIG.m` to decode the MCS/bandwidth/PSDU length bits in `HTSIG`.

## Reference

If you find our work useful in your research, please consider citing our paper:

```console
@inproceedings{gao2023swirls,
  title={Swirls: Sniffing {Wi-Fi} using radios with low sampling rates},
  author={Gao, Zhihui and Chen, Yiran and Chen, Tingjun},
  booktitle={Proc. ACM MobiHoc'23},
  year={2023}
}
```

If you have any further questions, please feel free to contact us at :D

zhihui.gao@duke.edu
