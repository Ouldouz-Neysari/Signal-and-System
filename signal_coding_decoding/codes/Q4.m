clc;
clear;
close all;

keys = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z',' ','.',',','!',';','"'];
Mapset = cell(2, 32);
for i=0:31
    Mapset{1, i+1}=keys(i+1);
    Mapset{2, i+1}=dec2bin(i,5);
end

message='signal';
bit_rate=1;
noise_effect=0;

[coded_signal, divisible, message_length, bits_freq]=coding_freq(message, bit_rate, Mapset, noise_effect);
decoded_signal = decoding_freq(coded_signal, bit_rate, Mapset, divisible, message_length, noise_effect, bits_freq);

fprintf('\n');
fprintf('%s',"The decoded signal frequencies: " ,decoded_signal{:});
fprintf('\n');

function [coded_signal, divisible, message_length, bits_freq] = coding_freq(message, bit_rate,Mapset,noise_effect)
    message_length = strlength(message);
    total_bits = 5*message_length;
    tstart=0;
    tend=ceil(total_bits/bit_rate);
    fs=100;
    ts=1/fs;
    t=tstart:ts:tend-ts;
    binary_form = strings(1, message_length);
    freq_count = 2^bit_rate;
    bits_freq=zeros(1, freq_count);
    step=floor(49/freq_count);
    start_freq=floor((49-(freq_count-1)*step)/2);
    coded_signal=0;

    if freq_count<50
        for i=1:freq_count
            bits_freq(i)=start_freq+(i-1)*step;
        end
    else
        for i=1:freq_count
            bits_freq(i)=rem(i, 50);
        end
    end

    for i=1:message_length
        for j=1:32
            if message(i) == Mapset{1, j}
                binary_form(i) = Mapset(2, j);
                break;
            end
        end
    end

    binary_form=char(join(binary_form, ''));

    for i=0:tend-1
        if (i+1)*bit_rate<=total_bits
            bits=binary_form(i*bit_rate+1:(i+1)*bit_rate);
        else
            bits = binary_form(i*bit_rate+1:total_bits);
        end
        f=bits_freq(bin2dec(bits)+1);
        each_freq_part = (heaviside(t-i)-heaviside(t-i-1));
        coded_signal=coded_signal + sin(2*pi*f*t).* each_freq_part;
    end
    
    noise_func = noise_effect * randn(1, length(coded_signal));
    coded_signal=coded_signal+ noise_func;

    if rem(total_bits, bit_rate)==0
        divisible=true;
    else
        divisible=false;
    end
    
    figure();
    subplot(2,1,1);
    plot(t, coded_signal);
    xlabel 't'
    ylabel 'coded_signal'

end

function decoded_signal = decoding_freq(coded_signal, bit_rate, Mapset, divisible, message_length, noise_effect, bits_freq)

    fs=100;
    tend=length(coded_signal)/fs;
    corr_results=zeros(1, tend);
    decoded_signal=strings(1, message_length);
    binary_form=strings(1, tend);
    freq_count=2^bit_rate; 
    total_bits =5*message_length;
    
    for i=1:tend
        [~, fmax]=max(abs(fftshift(fft(coded_signal((i-1)*fs+1:i*fs)))));
        corr_results(i)=abs(fmax-51);
    end

    if noise_effect~=0
        for i=1:tend
            diff=1000000000000;
            empty_or_not=true;
            for j=1:freq_count-1
                first_diff=abs(corr_results(i)-bits_freq(j));
                second_diff=abs(corr_results(i)-bits_freq(j+1));
                if second_diff<first_diff && second_diff<diff
                    default=j;
                    diff=second_diff;
                end
                if first_diff<second_diff && first_diff<diff
                    default=j-1;
                    diff=first_diff;
                end
                threshold=(bits_freq(j)+bits_freq(j+1))/2;
                if corr_results(i)>=bits_freq(j) && corr_results(i)<=threshold
                    empty_or_not=false;
                    if divisible || i~=tend
                        binary_form(i)=dec2bin(j-1, bit_rate);
                    else
                        binary_form(i)=dec2bin(j-1, 5*message_length-bit_rate*(i-1));
                    end
                    break;
                end
                if corr_results(i)<=bits_freq(j+1) && corr_results(i)>threshold
                    empty_or_not=false;
                    if divisible || i~=tend
                        binary_form(i)=dec2bin(j, bit_rate);
                    else
                        binary_form(i)=dec2bin(j, total_bits-bit_rate*(i-1));
                    end
                    break;
                end
            end
            if empty_or_not
                if divisible || i~=tend
                    binary_form(i)=dec2bin(default, bit_rate);
                else
                    binary_form(i)=dec2bin(default, total_bits-bit_rate*(i-1));
                end
            end
        end
    else
        for i=1:tend
            for j=1:freq_count
                if corr_results(i)==bits_freq(j)
                    if divisible || i~=tend
                        binary_form(i)=dec2bin(j-1, bit_rate);
                    else
                        binary_form(i)=dec2bin(j-1, total_bits-bit_rate*(i-1));
                    end
                    break;
                end
            end
        end
    end

    binary_form=char(join(binary_form, ''));

    for i=1:message_length
        for j=1:32
            if Mapset{2, j} == binary_form((i-1)*5+1:(i*5))
                decoded_signal(i)=Mapset{1, j};
                break;
            end
        end
    end

end
