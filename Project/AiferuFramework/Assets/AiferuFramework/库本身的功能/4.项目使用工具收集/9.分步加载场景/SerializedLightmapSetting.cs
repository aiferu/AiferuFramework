using UnityEngine;

[ExecuteInEditMode]//使此MonoBehaviour脚本可以在编辑器模式下运行
public class SerializedLightmapSetting : MonoBehaviour
{
    [HideInInspector]
    public Texture2D[] lightmapFar, lightmapNear;
    [HideInInspector]
    public LightmapsMode mode;
#if UNITY_EDITOR
    public void OnEnable()
    {
        Debug.LogError("[SerializedLightmapSetting] hook");
        //(已过时Unity2021.3.5)UnityEditor.Lightmapping.completed += LoadLightmaps;
        //使用Bakery插件进行烘焙时,并不能很好的激活这个时间,所以改用手动调用
        UnityEditor.Lightmapping.bakeCompleted += LoadLightmaps;

    }
    public void OnDisable()
    {
        Debug.LogError("[SerializedLightmapSetting] unhook");
        //(已过时Unity2021.3.5)UnityEditor.Lightmapping.completed -= LoadLightmaps;
        UnityEditor.Lightmapping.bakeCompleted -= LoadLightmaps;
    }
#endif
    public void Start()
    {
        if (Application.isPlaying)
        {
            LightmapSettings.lightmapsMode = mode;
            int l1 = (lightmapFar == null) ? 0 : lightmapFar.Length;
            int l2 = (lightmapNear == null) ? 0 : lightmapNear.Length;
            int l = (l1 < l2) ? l2 : l1;
            LightmapData[] lightmaps = null;
            if (l > 0)
            {
                lightmaps = new LightmapData[l];
                for (int i = 0; i < l; i++)
                {
                    lightmaps[i] = new LightmapData();
                    if (i < l1)
                        //(已弃用Unity2021.3.5)lightmaps[i].lightmapFar = lightmapFar[i];
                        lightmaps[i].lightmapColor = lightmapFar[i];
                    if (i < l2)
                        //(已弃用Unity20221.3.5)lightmaps[i].lightmapNear = lightmapNear[i];
                        lightmaps[i].lightmapDir = lightmapNear[i];
                }
            }
            LightmapSettings.lightmaps = lightmaps;
            Destroy(this);
        }
    }
#if UNITY_EDITOR
    public void LoadLightmaps()
    {
        Debug.Log("光照贴图烘焙完成");
        mode = LightmapSettings.lightmapsMode;
        lightmapFar = null;
        lightmapNear = null;
        if (LightmapSettings.lightmaps != null && LightmapSettings.lightmaps.Length > 0)
        {
            int l = LightmapSettings.lightmaps.Length;
            lightmapFar = new Texture2D[l];
            lightmapNear = new Texture2D[l];
            for (int i = 0; i < l; i++)
            {
                lightmapFar[i] = LightmapSettings.lightmaps[i].lightmapColor;
                lightmapNear[i] = LightmapSettings.lightmaps[i].lightmapDir;
            }
        }
        MeshLightmapSetting[] savers = GameObject.FindObjectsOfType<MeshLightmapSetting>();
        foreach (MeshLightmapSetting s in savers)
        {
            s.SaveSettings();
        }
    }
#endif
}