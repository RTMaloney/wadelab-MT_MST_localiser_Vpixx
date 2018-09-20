function  [y, h] = resample( x, p, q, N, beta )
%RESAMPLE  Change the sampling rate of a signal
%   Y = RESAMPLE(X,P,Q) resamples the sequence in vector X at P/Q times
%   the original sample rate using a polyphase implementation. 
%   The resulting vector is P/Q times the length of X.  P and Q must be 
%   positive integers.
%
%   RESAMPLE applies an anti-aliasing (lowpass) FIR filter to X during the 
%   resampling process.  The filter is designed using FIR1 with a Kaiser 
%   window.
%
%   Y = RESAMPLE(X,P,Q,N) uses N terms on either side of X[n] to perform
%   the resampling.  The length of the FIR filter RESAMPLE uses is 
%   proportional to N; by increasing N you get better accuracy at the 
%   expense of more computation time.  If you don't specify N, RESAMPLE uses
%   N = 10 by default.  If you let N = 0, RESAMPLE uses a zero-order hold.
%
%   Y = RESAMPLE(X,P,Q,N,BETA) uses BETA as the design parameter for the 
%   Kaiser window used to design the filter.  RESAMPLE uses BETA = 5 if
%   you don't include it.
%
%   Y = RESAMPLE(X,P,Q,B) uses B to filter X if B is a vector of filter 
%   coefficients. 
%
%   [Y,B] = RESAMPLE(X,P,Q,...) returns in B the coefficients of the filter
%   applied to X during the resampling process.  
%
%   If X is a matrix, RESAMPLE resamples the columns of X.
%
%   See also UPFIRDN, INTERP, DECIMATE, FIR1, KAISER, INTFILT.

%   NOTE-1: digital anti-alias filter is desiged via windowing

%   Author(s): James McClellan, 6-11-93
%              Modified to use upfirdn, T. Krauss, 2-27-96
%   Copyright (c) 1988-96 by The MathWorks, Inc.
%   $Revision: 1.15 $  $Date: 1996/07/25 16:39:37 $

if nargin < 5,  beta = 5;  end   %--- design parameter for Kaiser window LPF
if nargin < 4,   N = 10;   end
if abs(round(p))~=p | p==0, error('P must be a positive integer.'), end
if abs(round(q))~=q | q==0, error('Q must be a positive integer.'), end
[row,col]=size(x);

[p,q] = rat( p/q, 1e-12 );  %--- reduce to lowest terms 
   % (usually exact, sometimes not; loses at most 1 second every 10^12 seconds)
if (p==1)&(q==1)
    y = x; 
    h = 1;
    return
end
pqmax = max(p,q);
if length(N)>1      % use input filter
   L = length(N);
   h = N;
else                % design filter
   if( N>0 )
      fc = 1/2/pqmax;
      L = 2*N*pqmax + 1;
      h = p*firls( L-1, [0 2*fc 2*fc 1], [1 1 0 0]).*kaiser(L,beta)' ;
      % h = p*fir1( L-1, 2*fc, kaiser(L,beta)) ;
   else
      L = p;
      h = ones(1,p);
   end
end

Lhalf = (L-1)/2;
isvect = any(size(x)==1);
if isvect
    Lx = length(x);
else
    [Lx,num_sigs]=size(x);
end

% Need to delay output so that downsampling by q hits center tap of filter.
nz = floor(q-mod(Lhalf,q));
z = zeros(1,nz);
h = [z h(:)'];
Lhalf = Lhalf + nz;

% ----  HERE'S THE CALL TO UPFIRDN  ----------------------------
y = upfirdn(x,h,p,q);

% Get rid of trailing and leading data so input and output signals line up
% temporally:
if isvect
    y(1:floor(ceil(Lhalf)/q)) = [];
    y(ceil(Lx*p/q)+1:end) = [];
else
    y(1:floor(ceil(Lhalf)/q),:) = [];
    y(ceil(Lx*p/q)+1:end,:) = [];
end

h(1:nz) = [];  % get rid of leading zeros in case filter is output too

