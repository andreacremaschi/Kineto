__kernel void masksourcewithmaskchannel(__rd image2d_t srcimg, 
						__rd image2d_t maskimg, 
						int channel,
						__wr image2d_t dstimg)
{
	int2	pos = (int2)(get_global_id(0), get_global_id(1));
	float4	color1 = read_imagef(srcimg, CLK_ADDRESS_CLAMP_TO_EDGE | CLK_FILTER_NEAREST, pos);
	float4	color2 = read_imagef(maskimg, CLK_ADDRESS_CLAMP_TO_EDGE | CLK_FILTER_NEAREST, pos);
	
	write_imagef(dstimg, pos, color1*color2[channel]);
}
