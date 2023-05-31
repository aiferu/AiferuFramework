#if UNITY_EDITOR
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
namespace AiferuFramework.ArtBrushTool
{
    [InitializeOnLoad]
    public class PaintDetailsEXtends
    {
        private static int layerMask =0;
        #region �󶨳���GUI��Ⱦ�ص�
        static PaintDetailsEXtends()
        {
            //�󶨳���GUI��Ⱦ��
            SceneView.duringSceneGui += OnSceneGUI;
        }

        //~PaintDetailsEXtends()
        //{
        //    SceneView.duringSceneGui -= OnSceneGUI;
        //}
        #endregion

        //Scene���ص�����
        static void OnSceneGUI(SceneView view)
        {
            if (ArtBrushToolEW.ins == null)
                return;
            //�ж��Ƿ���������ˢ�ݹ���
            if (ArtBrushToolEW.ins.Enable)
            {
                Planting();
            }
        }


        static void Planting()
        {
            //ʹ������ȡ���潻��
            Event e = Event.current;
            //�����������ʱ
            RaycastHit raycastHit = new RaycastHit();
            Ray terrainRay = HandleUtility.GUIPointToWorldRay(e.mousePosition);
            //Debug.DrawLine(terrainRay.origin, terrainRay.GetPoint(100), Color.red);
            if (Physics.Raycast(terrainRay, out raycastHit, Mathf.Infinity))
            {
                //������껮��λ�úͱ༭��������õ��ܶȵȲ���ʵ����ֲ�� �����ϱ��
            }
            //���Ʊ�ˢ
            DrawBrush(raycastHit);
        }
        /// <summary>
        /// ���Ʊ�ˢ
        /// </summary>
        private static void DrawBrush(RaycastHit hit)
        {
            if (ArtBrushToolEW.ins.BrushEnable)
            {
                //���ñ༭ģʽΪ��,����ˢ��ˢ��ʱ����޷�ʹ���ƶ���ת��
                Tools.current = Tool.None;
                //����Ĭ�ϵ�ѡ��,�����Ͳ���ѡ������
                HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));

                //���Ʊ�ˢ��ʽ
                Handles.color = new Color(1,1,1,0.1f);
                Handles.DrawSolidDisc(hit.point, hit.normal, ArtBrushToolEW.ins.data.BrushSize/2);
                Handles.color = Color.red;
                Handles.DrawWireDisc(hit.point, hit.normal, ArtBrushToolEW.ins.data.BrushSize/2);
                Handles.DrawLine(hit.point, hit.point+(hit.normal* ArtBrushToolEW.ins.data.BrushSize / 2));
            }

        }
    }
}
#endif
