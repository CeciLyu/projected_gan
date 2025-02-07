# original implementation: https://github.com/odegeasslbc/FastGAN-pytorch/blob/main/models.py
#
# modified by Axel Sauer for "Projected GANs Converge Faster"
#
import torch.nn as nn
from pg_modules.blocks import (InitLayer, UpBlockBig, UpBlockBigCond, UpBlockSmall, UpBlockSmallCond, SEBlock, conv2d, Self_Attn)


def normalize_second_moment(x, dim=1, eps=1e-8):
    return x * (x.square().mean(dim=dim, keepdim=True) + eps).rsqrt()


class DummyMapping(nn.Module):
    def __init__(self):
        super().__init__()

    def forward(self, z, c, **kwargs):
        return z.unsqueeze(1)  # to fit the StyleGAN API


class FastganSynthesis(nn.Module):
    def __init__(self, attn_res, ngf=128, z_dim=256, nc=3, img_resolution=256, lite=False):
        super().__init__()
        self.img_resolution = img_resolution
        self.z_dim = z_dim
        self.attn_res = attn_res
        # channel multiplier
        nfc_multi = {2: 16, 4:16, 8:8, 16:4, 32:2, 64:2, 128:1, 256:0.5,
                     512:0.25, 1024:0.125}
        nfc = {}
        for k, v in nfc_multi.items():
            nfc[k] = int(v*ngf)

        # layers
        self.init = InitLayer(z_dim, channel=nfc[2], sz=4)

        UpBlock = UpBlockSmall if lite else UpBlockBig # in_planes, out_planes

        self.feat_8   = UpBlock(nfc[4], nfc[8])
        self.feat_16  = UpBlock(nfc[8], nfc[16])
        self.feat_32  = UpBlock(nfc[16], nfc[32])
        self.feat_64  = UpBlock(nfc[32], nfc[64])
        self.feat_128 = UpBlock(nfc[64], nfc[128])
        self.feat_256 = UpBlock(nfc[128], nfc[256])

        self.se_64  = SEBlock(nfc[4], nfc[64]) # ch_in, ch_out
        self.se_128 = SEBlock(nfc[8], nfc[128])
        self.se_256 = SEBlock(nfc[16], nfc[256])
        
        if not attn_res is None:
            self.attn = Self_Attn(inChannels = nfc[attn_res], k = 8)

        self.to_big = conv2d(nfc[img_resolution], nc, 3, 1, 1, bias=True)

        if img_resolution > 256:
            self.feat_512 = UpBlock(nfc[256], nfc[512])
            self.se_512 = SEBlock(nfc[32], nfc[512])
        if img_resolution > 512:
            self.feat_1024 = UpBlock(nfc[512], nfc[1024])

    def forward(self, input, c, return_attn_map = False, **kwargs):
        # map noise to hypersphere as in "Progressive Growing of GANS"
        input = normalize_second_moment(input[:, 0])

        feat_4 = self.init(input)
        feat_8 = self.feat_8(feat_4)
        feat_16 = self.feat_16(feat_8)
        if self.attn_res == 16:
            feat_16, g_attn_map = self.attn(feat_16)
        feat_32 = self.feat_32(feat_16)
        if self.attn_res == 32:
            feat_32, g_attn_map = self.attn(feat_32)
        feat_64 = self.se_64(feat_4, self.feat_64(feat_32)) # feat_small, feat_big
        if self.attn_res == 64:
            feat_64, g_attn_map = self.attn(feat_64)
        feat_128 = self.se_128(feat_8,  self.feat_128(feat_64))
        if self.attn_res == 128:
            feat_128, g_attn_map = self.attn(feat_128)

        if self.img_resolution >= 128:
            feat_last = feat_128

        if self.img_resolution >= 256:
            feat_last = self.se_256(feat_16, self.feat_256(feat_last))

        if self.img_resolution >= 512:
            feat_last = self.se_512(feat_32, self.feat_512(feat_last))

        if self.img_resolution >= 1024:
            feat_last = self.feat_1024(feat_last)

        if self.attn_res == 256:
            feat_last, g_attn_map = self.attn(feat_last)

        if not self.attn_res is None and return_attn_map:
            return self.to_big(feat_last), g_attn_map
        else:
            return self.to_big(feat_last)


# class FastganSynthesisCond(nn.Module):
#     def __init__(self, ngf=64, z_dim=256, nc=3, img_resolution=256, num_classes=1000, lite=False):
#         super().__init__()

#         self.z_dim = z_dim
#         nfc_multi = {2: 16, 4:16, 8:8, 16:4, 32:2, 64:2, 128:1, 256:0.5,
#                      512:0.25, 1024:0.125, 2048:0.125}
#         nfc = {}
#         for k, v in nfc_multi.items():
#             nfc[k] = int(v*ngf)

#         self.img_resolution = img_resolution

#         self.init = InitLayer(z_dim, channel=nfc[2], sz=4)

#         UpBlock = UpBlockSmallCond if lite else UpBlockBigCond

#         self.feat_8   = UpBlock(nfc[4], nfc[8], z_dim)
#         self.feat_16  = UpBlock(nfc[8], nfc[16], z_dim)
#         self.feat_32  = UpBlock(nfc[16], nfc[32], z_dim)
#         self.feat_64  = UpBlock(nfc[32], nfc[64], z_dim)
#         self.feat_128 = UpBlock(nfc[64], nfc[128], z_dim)
#         self.feat_256 = UpBlock(nfc[128], nfc[256], z_dim)

#         self.se_64 = SEBlock(nfc[4], nfc[64])
#         self.se_128 = SEBlock(nfc[8], nfc[128])
#         self.se_256 = SEBlock(nfc[16], nfc[256])

#         self.to_big = conv2d(nfc[img_resolution], nc, 3, 1, 1, bias=True)

#         if img_resolution > 256:
#             self.feat_512 = UpBlock(nfc[256], nfc[512])
#             self.se_512 = SEBlock(nfc[32], nfc[512])
#         if img_resolution > 512:
#             self.feat_1024 = UpBlock(nfc[512], nfc[1024])

#         self.embed = nn.Embedding(num_classes, z_dim)

#     def forward(self, input, c, update_emas=False):
#         c = self.embed(c.argmax(1))

#         # map noise to hypersphere as in "Progressive Growing of GANS"
#         input = normalize_second_moment(input[:, 0])

#         feat_4 = self.init(input)
#         feat_8 = self.feat_8(feat_4, c)
#         feat_16 = self.feat_16(feat_8, c)
#         feat_32 = self.feat_32(feat_16, c)
#         feat_64 = self.se_64(feat_4, self.feat_64(feat_32, c))
#         feat_128 = self.se_128(feat_8,  self.feat_128(feat_64, c))

#         if self.img_resolution >= 128:
#             feat_last = feat_128

#         if self.img_resolution >= 256:
#             feat_last = self.se_256(feat_16, self.feat_256(feat_last, c))

#         if self.img_resolution >= 512:
#             feat_last = self.se_512(feat_32, self.feat_512(feat_last, c))

#         if self.img_resolution >= 1024:
#             feat_last = self.feat_1024(feat_last, c)

#         return self.to_big(feat_last)


class Generator(nn.Module):
    def __init__(
        self,
        z_dim=256,
        c_dim=0,
        w_dim=0,
        img_resolution=256,
        img_channels=3,
        ngf=128,
        cond=0,
        mapping_kwargs={},
        synthesis_kwargs={}
    ):
        super().__init__()
        self.z_dim = z_dim
        self.c_dim = c_dim
        self.w_dim = w_dim
        self.img_resolution = img_resolution
        self.img_channels = img_channels
        self.attn_res = synthesis_kwargs.attn_res

        # Mapping and Synthesis Networks
        self.mapping = DummyMapping()  # to fit the StyleGAN API
        Synthesis = FastganSynthesisCond if cond else FastganSynthesis
        self.synthesis = Synthesis(ngf=ngf, z_dim=z_dim, nc=img_channels, img_resolution=img_resolution, **synthesis_kwargs)

    def forward(self, z, c, return_attn_map = False, **kwargs):
        w = self.mapping(z, c)
        
        #print(return_attn_map)
        if return_attn_map and not self.attn_res is None:
            img, g_attn_map  = self.synthesis(w, c, return_attn_map = return_attn_map)
            return img, g_attn_map
        else: 
            img = self.synthesis(w, c, return_attn_map = return_attn_map)
            return img
