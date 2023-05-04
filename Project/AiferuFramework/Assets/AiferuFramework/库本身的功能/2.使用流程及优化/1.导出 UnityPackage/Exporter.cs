using System;
using System.IO;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

namespace AiferuFramework
{
    public class Exporter
    {
        private static string GeneratePackageName()
        {
            return "AiferuFramework_" + DateTime.Now.ToString("yyyyMMdd_HH_mm");
        }

#if UNITY_EDITOR
        //%e 这项菜单的快捷键为ctrl+e -----------------------------------------------↓
        //false 暂时用不着 ----------------------------------------------------------------↓
        //菜单项排序用，序号越小越靠前 ----------------------------------------------------------↓
        [MenuItem("AiferuFramework/库本身的功能/2.使用流程及优化/1.导出 UnityPackage %e", false, 2001)]
        static void MenuClicked1()
        {
            EditorUtil.ExportPackage("Assets/AiferuFramework", GeneratePackageName() + ".unitypackage");
            EditorUtil.OpenInFolder(Path.Combine(Application.dataPath, "../"));
        }
#endif

    }
}