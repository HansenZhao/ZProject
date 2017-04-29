[fileName,filePath] = uigetfile();
x = importdata(strcat(filePath,fileName));
pd = ParticleData(x.data);
pa = ParticleAnalysis(pd,0.5);
pa.plotTransientDir(0,1,1);