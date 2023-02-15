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

[coded_signal, divisible, message_length]=coding_amp(message, bit_rate,noise_effect, Mapset);
decoded_signal = decoding_amp(coded_signal, bit_rate, Mapset, divisible, message_length, noise_effect);

fprintf('\n');
fprintf('%s',"The decoded message from the signal: " ,decoded_signal{:});
fprintf('\n');

function [coded_signal, divisible, message_length] = coding_amp(message, bit_rate,noise_effect, Mapset)
    fs=100;
    ts=1/fs;
    message_length = strlength(message);
    total_bits = 5 * message_length;
    tstart=0;
    tend=ceil(total_bits/bit_rate);
    t=tstart:ts:tend-ts;
    
    binary_form = strings(1, message_length);
    singals_count = 2^bit_rate;

    for i=1:message_length
        for j=1:32
            if message(i) == Mapset{1, j}
                binary_form(i) = Mapset(2, j);
                break;
            end
        end
    end

    binary_form=char(join(binary_form, ''));
    coded_signal=0;

    for i=0:tend-1
        if (i+1)*bit_rate<=total_bits
            bits=binary_form(i*bit_rate+1:(i+1)*bit_rate);
        else
            bits = binary_form(i*bit_rate+1:total_bits);
        end

        each_signal_part = heaviside(t-i)-heaviside(t-i-1);
        each_coefficient = (bin2dec(bits)/(singals_count-1));
        coded_signal = coded_signal + each_coefficient * sin(2*pi*t).* (each_signal_part);
    end

    noise_effect_func = noise_effect * randn(1, length(coded_signal));
    coded_signal=coded_signal+ noise_effect_func;

    if rem(total_bits, bit_rate)==0
        divisible=true;
    else
        divisible=false;
    end

    figure();
    subplot(2,1,1)
    plot(t, coded_signal)
    xlabel 't'
    ylabel 'coded_signal'

end

function decoded_signal = decoding_amp(coded_signal, bit_rate, Mapset, divisible, message_length, noise_effect)
    fs=100;
    tend=length(coded_signal)/fs;
    tstart=0;
    ts=1/fs;
    t=tstart:ts:tend-ts;
    total_coefficients=2^bit_rate;
    xt=2*sin(2*pi*t);
    first_result=coded_signal.*xt;
    corr_result = zeros(1, tend);
    coefficients=zeros(1, total_coefficients);
    total_bits = 5*message_length;
    
    for i=1:tend
        each_corr = first_result(((i-1)*fs)+1:i*fs);
        corr_result(i)=0.01*sum(each_corr);
    end
    
    for i=0:total_coefficients-1
        coefficients(i+1)=i/(total_coefficients-1);
    end

    binary_form=strings(1, tend);
    decoded_signal = strings(1, message_length);
    
    
    if noise_effect ~= 0
        for i=1:tend
            diff=1000;
            empty_or_not=true;
            for j=1:total_coefficients-1
                first_diff=abs(corr_result(i)-coefficients(j));
                second_diff=abs(corr_result(i)-coefficients(j+1));
                threshold=(coefficients(j)+coefficients(j+1))/2;

                if second_diff<first_diff && second_diff<diff
                    default=j;
                    diff=second_diff;
                end

                if first_diff<second_diff && first_diff<diff
                    default=j-1;
                    diff=first_diff;
                end

                if corr_result(i)>=coefficients(j) && corr_result(i)<=threshold
                    empty_or_not=false;
                    if divisible || i ~=tend
                        binary_form(i)=dec2bin(j-1, bit_rate);
                    else
                        binary_form(i)=dec2bin(j-1, total_bits-bit_rate*(i-1));
                    end
                    break;
                end

                if corr_result(i)<=coefficients(j+1) && corr_result(i)>threshold
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
                if divisible || i ~= tend
                    binary_form(i)=dec2bin(default, bit_rate);
                else
                    binary_form(i)=dec2bin(default, total_bits-bit_rate*(i-1));
                end
            end
        end
    else
        threshold=1/(((2^bit_rate)-1)*2);
        for i=1:tend
            for j=1:total_coefficients
                if abs(corr_result(i)-coefficients(j))<threshold
                    if divisible || i ~=tend
                        binary_form(i)=dec2bin(j-1, bit_rate);
                    else
                        binary_form(i)=dec2bin(j-1, total_bits - bit_rate*(i-1));
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

