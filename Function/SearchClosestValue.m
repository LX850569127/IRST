function [ indexOfRow ] = SearchClosestValue(array,reference)
%Function:寻找数组中最接近参考值的数所在的行
%Input:数组(array)、参考值(reference)
%Output:indexOfRow(最接近的纬度值所在的行)

difference=array-reference;       %差值
minValue=min(abs(difference));    %差值的最小值
indexOfRow=find(minValue==abs(difference));  %差值的最小值所在的行
end

