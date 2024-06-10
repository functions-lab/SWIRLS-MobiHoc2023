# MobiHoc'23 SWIRLS

## Prerequisite

**MATLAB**
1. `WLAN Toolbox`

### Step 1: Unzip Data

Unzip `Data.zip` for all the received Wi-Fi packet waveforms in 802.11n (high throughput) with 

1. Different low sampling rates $f_s$ and their corresponding carrier frequency distances $\Delta f$;
2. Different SNR levels.

### Step 2: Perform SWIRLS

In MATLAB, run `main_LSIG.m` to decode the `LSIG`, including the packet property of

1. Transmission time (12 bits)

In MATLAB, run `main_HTSIG.m` to decode the `LSIG`, including the packet property of

1. Modulation and Coding Scheme (5 bits)
2. Bandwidth (1 bit)
3. PSDU Length (16 bits)


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
